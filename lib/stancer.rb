class Issues
  
  def initialize(filename)
    @filename = filename
    @issues = JSON.parse(File.read(@filename))
  end

  def issue(id)
    found = @issues.detect { |i| i['id'] == id }
    raise "No such issue (#{id})" if found.nil?
    Issue.new(found)
  end
  
end

class Issue

  def initialize(data)
    @data = data
  end

  def aggregate_on (hash)
    (@__a ||= {})[hash] = WeightedAggregate.new( { aspects: aspects }.merge hash)
  end

  def aspects
    aspects = @data['aspects']
    raise "No aspects in #{@data}" if aspects.nil?
    return aspects
  end

end

class Score
  # num_votes / score / max 
  def initialize args
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
    @weight = weight
  end

  # TODO this only works when vote ranges are 0..max
  # FIXME for negatives, or other ranges, by calculating min_score too
  def weight
    @num_votes.zero? ? 0.5 : @score / @max
  end

  def +(other)
    Score.new(
      num_votes: @num_votes + other[:num_votes],
      score:     @score + other[:score],
      max:       @max + other[:max],
    )
  end

  def [](arg)
    instance_variable_get("@#{arg}")
  end

end


class WeightedAggregate

  # Required: aspects 
  # May take: motions / filter / bloc
  def initialize args
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
    raise "Need aspects" if @aspects.nil?
    @motion ||= @aspects.map { |a| a['motion_id'] } 
  end

  def aggregate
    @__agg ||= Aggregate.new(bloc: @bloc, filter: @filter, motion: @motion)
  end

  def weighted_blocs
    @__wb ||= Hash[ 
      aggregate.bloc_aggregates.map { |bloc, aggs|
        [ bloc,  aggs.map { |ai| weighted_aggregate(ai) } ]
      }
    ]
  end

  def scored_blocs
    return __combined_blocs
  end

  def score(bloc=nil)
    sb = scored_blocs
    return sb[bloc] unless sb.empty?
    # TODO I don't like hard-coding this here. It should just sum as
    # normal, but to zero
    return Score.new(
      num_votes: 0,
      score: 0,
      max: 0,
    )
  end


  private

  # FIXME This seems back to front. We should always know what aspect
  # we're working with.
  def aspect_for(motionid)
    @aspects.detect { |a| a['motion_id'] == motionid }
  end

  # score a given aggregate by looking up the weights for that motion in
  # the given Aspect(s)
  def weighted_aggregate (ai)
    motionid = ai['motion_id']
    aspect = aspect_for(motionid) or raise "No votes on #{motionid}" 
    weights = aspect['weights']

    votes     = ai['counts']
    num_votes = votes.values.map(&:to_i).reduce(:+)
    max_score = weights.values.max * num_votes
    score = votes.map { |option, count| weights[option] * count }.reduce(:+)

    return Score.new( 
      num_votes: num_votes,
      score: score,
      max: max_score,
    )
  end

  def __combined_blocs
    @__cb ||= Hash[
      weighted_blocs.map { |bloc,waggs| [ bloc, waggs.reduce(:+) ] }
    ]
  end

end

class Aggregate
  # Look up the relevant motion(s) on the voteit-api server
  # Knows nothing about Issues/Aspects etc.
 
  require 'json'

  require 'open-uri/cached'
  OpenURI::Cache.cache_path = '/tmp/cache'

  # FIXME make this more easily configurable
  @@SERVER = 'http://localhost:5000'
  @@API    = '/api/1'

  # TODO: restrict to motion / filter / bloc
  def initialize args
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def bloc_aggregates
    bloc_keys = blocs
    abort "Can't handle multi-blocs yet" if bloc_keys.size > 1
    aggregates.group_by { |ai| ai['bloc'][bloc_keys.first] }
  end

  def blocs
    aggregate_json['request']['blocs'].reject(&:empty?)
  end

  private
  def aggregates
    @__agg ||= aggregate_json['aggregate'] 
  end

  def aggregate_url
    @@SERVER + @@API + "/aggregate?" + URI.encode_www_form(motion: @motion, filter: @filter, bloc: @bloc)
  end

  def aggregate_txt
    @__txt ||= open(aggregate_url).read
  end

  def aggregate_json
    @__json ||= JSON.parse(aggregate_txt)
  end

end
