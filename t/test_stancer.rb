#!/usr/bin/ruby

require 'stancer'
require 'minitest/autorun'

describe "For an aggregate" do

  describe "when dealing with a bloc" do

    before do
      @agg = Aggregate.new(bloc:'voter.id', filter: 'party.id:sdlp', motion: 'pw-2003-02-26-96' )
    end

    it "should have one bloc" do
      @agg.blocs.size.must_equal 1
      @agg.blocs.first.must_equal 'voter.id'
    end

    it "should have a bloc_aggregate for each MP" do
      ba = @agg.bloc_aggregates
      ba.keys.size.must_equal 3
      ba['john_hume'].size.must_equal 1
      # JSON.pretty_generate(ba).must_equal "foo"
    end

  end 

end

describe "For a Weighted Aggregate" do 

  describe "when dealing with a single motion" do

    before do
      @wa = Issues.new('issues.json').issue('PW-1110').aggregate_on(
        bloc:'voter.id',
        filter: 'party.id:sdlp', 
        motion: 'pw-2010-07-06-14',
      )
    end

    it "should have three weighted blocs" do
      @wa.weighted_blocs.count.must_equal 3
    end

    it "should score Margaret Ritchie OK" do
      wb = @wa.weighted_blocs['margaret_ritchie']
      wb.count.must_equal 1

      wb[0][:num_votes].must_equal 1
      wb[0][:score].must_equal 25
      wb[0][:max].must_equal 50
    end

    it "should have a scored bloc for each MP" do
      @wa.scored_blocs.count.must_equal 3
    end

    it "should score Margaret Ritchie OK" do
      sb = @wa.score('margaret_ritchie')
      sb[:num_votes].must_equal 1
      sb[:score].must_equal 25
      sb[:max].must_equal 50
    end

  end

  describe "when dealing with multiple motions" do

    before do
      @wa = Issues.new('issues.json').issue('PW-1110').aggregate_on(
        bloc:'voter.id',
        filter: 'party.id:sdlp', 
        motion: [ 'pw-2010-07-06-14', 'pw-2010-07-13-18' ],
      )
    end

    it "should have a weighted bloc for each MP" do
      @wa.weighted_blocs.count.must_equal 3
    end

    it "should weight Margaret Ritchie OK" do
      wb = @wa.weighted_blocs['margaret_ritchie']
      wb.count.must_equal 2
      wb[0][:num_votes].must_equal 1
      wb[0][:score].must_equal 25
      wb[0][:max].must_equal 50
      wb[1][:num_votes].must_equal 1
      wb[1][:score].must_equal 0
      wb[1][:max].must_equal 10
    end

    it "should have a scored bloc for each MP" do
      @wa.scored_blocs.count.must_equal 3
    end

    it "should score Margaret Ritchie OK" do
      sb = @wa.score('margaret_ritchie')
      sb[:num_votes].must_equal 2
      sb[:score].must_equal 25
      sb[:max].must_equal 60
    end

  end
end

describe "When looking at an entire issue" do

  describe "when dealing with a single MP" do

    before do
      @wa = Issues.new('issues.json').issue('PW-1049').aggregate_on(filter: 'voter.id:david_cameron')
    end

    it "should get correct score/max" do
      # http://www.publicwhip.org.uk/mp.php?mpid=40665&dmp=1049
      sb = @wa.score 
      sb[:num_votes].must_equal 6
      sb[:score].must_equal 131
      sb[:max].must_equal 140
    end

  end

  describe "when dealing with a party" do

    before do
      @wa = Issues.new('issues.json').issue('PW-1049').aggregate_on(filter: 'party.id:sdlp')
    end

    it "should get correct score/max" do
      # http://www.publicwhip.org.uk/mp.php?mpid=1552&dmp=1049 (2)
      # http://www.publicwhip.org.uk/mp.php?mpid=984&dmp=1049 (52)
      # http://www.publicwhip.org.uk/mp.php?mpid=1091&dmp=1049 (52)
      sb = @wa.score 
      sb[:num_votes].must_equal 3*6
      sb[:score].must_equal 106
      sb[:max].must_equal 3*140
    end

  end

  describe "when dealing with a party who has never voted on the issue" do

    before do
      @wa = Issues.new('issues.json').issue('PW-1027').aggregate_on(filter: 'party.id:ukip')
    end

    it "should have no weighted blocs as no MPs voted" do
      @wa.weighted_blocs.count.must_equal 0
    end

    it "should have no scored blocs as no MPs voted" do
      @wa.weighted_blocs.count.must_equal 0
    end

    it "should score 0" do
      sb = @wa.score
      sb[:num_votes].must_equal 0
      sb[:score].must_equal 0
      sb[:max].must_equal 0
    end

  end

end
