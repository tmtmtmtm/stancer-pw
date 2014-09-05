module Stancer
  require 'json'

  class Motion

    # TODO different ways of loading: flatfiles, db, API, ...
    def self.configure(opt)
      fn = opt[:motions_file] or raise "Configuration missing: motions_file"
      @@motions = JSON.parse(File.read(fn))
    end

    def self.find(id)
      @@motions.find { |m| m['id'] == id }
    end
  end

  class Score

    def initialize(scores)
      @scores = scores
    end

    def to_h
      return { 
        weight: weight,
        score: total_score,
        num_votes: num_votes,
        num_motions: num_motions,
        min: min_score,
        max: max_score,
        counts: counts,
      }
    end

    def total_score 
      @scores.map { |a| a[:score] }.inject(:+) 
    end

    def num_motions 
      @scores.count 
    end

    # Number of votes actually cast: 
    #   if this is zero = "Never voted on X" rather than
    #   "Always abstained on X"
    # TODO: this version is UK specific, and should be configurable
    def num_votes 
      @scores.reject { |a| a[:option] == 'absent' }.count
    end

    def min_score
      @scores.map { |a| a[:min] }.inject(:+) 
    end

    def max_score
      @scores.map { |a| a[:max] }.inject(:+) 
    end

    def counts 
      @scores.group_by { |a| a[:option] }.map { |o,ss| { option: o, value: ss.count } } 
    end

    # TODO this only works when vote ranges are 0..max
    # FIXME for negatives, or other ranges, by calculating with min_score too
    def weight
      num_motions.zero? ? 0.5 : total_score.fdiv(max_score)
    end
      
  end


  class Stance

    def initialize(aspects, group, filter=nil)
      @aspects = aspects
      @group   = group  
      @filter  = filter # TODO make sure this is a Proc/lambda
    end

    def to_h
      Hash[ scored_votes.map { |bloc, as| [ bloc, Score.new(as).to_h ] } ]
    end

    private 

    def scored_votes
      @__scored_votes ||= score_votes!
    end

    def score_votes!
      scored_votes = {}
      @aspects.each do |a|
        a['motion']['vote_events'].each do |ve|
          wanted_votes = @filter.nil? ? ve['votes'] : ve['votes'].find_all(&@filter) 
          wanted_votes.each do |v|
            bloc = v[@group] or raise "No #{@group} in #{v}"
            # Need to collapse to ID as PW person hashes will have lots
            # of variations of the MP's name, for example
            key = bloc.is_a?(Hash) ? bloc['id'] : bloc
            (scored_votes[key] ||= []) << { 
              vote_event: ve['start_date'],
              voter: v['voter']['name'],
              option: v['option'],
              score: a['weights'][v['option']],
              min: a['weights'].values.min,
              max: a['weights'].values.max,
            }
          end
        end
      end
      return scored_votes
    end

  end

end
