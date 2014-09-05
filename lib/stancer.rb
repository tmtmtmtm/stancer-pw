class Stancer
  require 'json'
  require 'open-uri/cached'

  def initialize(opt)
    @opt = Options.new(opt)
  end

  def all_stances(group=@opt.grouping, filter=nil)
    all_issues.map { |i| issue_stance(i, group, filter).to_h }
  end
        
  private 

  def find_motion(id)
    all_motions.find { |m| m['id'] == id }
  end

  def all_issues
    # TODO convert these into Issue objects
    @issues ||= JSON.parse(open(@opt.issues_file).read)
  end

  def stance(aspects, group, filter=nil)
    Stance.new(aspects, group, filter)
  end

  # TODO move this into Issue class
  # issue_stance(i, 'party_id', lambda { |v| v['party_id'] == 'con' }).to_h
  # issue_stance(i, 'voter', lambda { |v| v['voter']['id'] == 'andy_burnham' }).to_h
  def issue_stance(i, group, filter=nil)
    warn "Processing issue #{i['id']}: #{i['text']}".green
    as = issue_aspects(i).map do |a| 
      a['motion'] = find_motion(a['motion_id']) or raise "No such motion"
      a
    end
    i['stances'] = stance(as, group, filter).to_h
    @opt.exclusions.each { |k| i.delete(k) }
    i
  end

  def issue_aspects(i)
    if i.has_key? 'aspects' 
      return i['aspects']
    else 
      return all_aspects.find_all { |a| a['issue_id'] == i['id'] }
    end
  end

  def all_motions
    @motions ||= JSON.parse(open(@opt.motions_file).read)
  end

  def all_aspects
    @aspects ||= JSON.parse(open(@opt.aspects_file).read)
  end


  #--------------------------------------------------------------------------

  class Options

    def initialize(opt)
      @opt = opt
    end

    def motions_file
      @opt[:motions_file] or raise "Configuration missing: motions_file"
    end

    def issues_file
      @opt[:issues_file] or raise "Configuration missing: issues_file"
    end

    def aspects_file
      @opt[:aspects_file] or raise "Configuration missing: aspects_file"
    end

    def grouping
      @opt[:grouping] or raise "Configuration missing: grouping"
    end

    def exclusions
      (@opt[:exclude] || "").split(/,\s*/)
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

    def _weighted_votes(vote_list, weight_hash)
      vote_list.map do |v|
        {
          option: v['option'],
          score: weight_hash[v['option']],
          min: weight_hash.values.min,
          max: weight_hash.values.max,
        }
      end
    end


    def score_votes!
      scored_votes = {}
      @aspects.each do |a|
        a['motion']['vote_events'].each do |ve|
          wanted_votes = @filter.nil? ? ve['votes'] : ve['votes'].find_all(&@filter) 
          wanted_votes.group_by { |v|
            bloc = v[@group] or raise "No #{@group} in #{v}"
            # Need to collapse to ID as PW person hashes will have lots
            # of variations of the MP's name, for example
            key = bloc.is_a?(Hash) ? bloc['id'] : bloc
          }.each do |key, votes|
            ((scored_votes[key] ||= []) << _weighted_votes(votes, a['weights'])).flatten!
          end
        end
      end
      return scored_votes
    end

  end

end
