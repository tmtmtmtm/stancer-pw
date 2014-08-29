module Stancer
  require 'json'

  class Motion

    # TODO different ways of loading: flatfiles, db, API, ...
    def self.configure(opt)
      fn = opt[:motion_file] or raise "Need a motion_file"
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
        min: min_score,
        max: max_score,
        counts: counts,
      }
    end

    def total_score 
      @scores.map { |a| a[:score] }.inject(:+) 
    end

    def num_votes 
      @scores.count 
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
      num_votes.zero? ? 0.5 : total_score.fdiv(max_score)
    end
      
  end


  class Stance

    def initialize(aspects, group, filter=nil)
      @aspects = aspects
      @group   = group  
      @filter  = filter # TODO make sure this is a Proc/lambda
    end

    def to_h
      Hash[ 
        scored_votes.map do |bloc, as| 
          # Yick. TODO have a better way to declare what value to key on
          key = bloc.is_a?(Hash) ? bloc['id'] : bloc
          [ key, Score.new(as).to_h ]  
        end
      ]
    end

    private 

    def scored_votes
      @__scored_votes ||= score_votes!
    end

    def score_votes!
      scored_votes = {}
      @aspects.each do |a|
        a['motion']['vote_events'].each do |ve|
          wanted_votes = @filter ? ve['votes'].find_all(&@filter) : ve['votes'].find_all
          wanted_votes.each do |v|
            bloc = v[@group] or raise "No #{@group} in #{v}"
            (scored_votes[bloc] ||= []) << { 
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
