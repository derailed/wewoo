require 'spec_helper'
require 'support/graph_sets'

describe Wewoo::ResultSet do
  let!(:g) { Wewoo::Graph.new( :test_graph ) }

  before :each do
    build_sample_graph( g )
  end

  context 'Vertex' do
    it 'collects vertices correctly' do
      expect( g.q("g.v(#{@v1.id}).out") ).to eq [@v2, @v4, @v3]
    end

    it 'fetch a single vertex correctly' do
      expect( g.q("g.v(#{@v1.id})") ).to eq @v1
    end
  end

  context 'Edge' do
    it 'collects edges correctly' do
      expect( g.q("g.v(#{@v1.id}).outE") ).to eq [@e7, @e8, @e9]
    end

    it 'fetch a single edge correctly' do
      expect( g.q("g.e('#{@e8.id}')") ).to eq @e8
    end
  end

  context 'Non Elements' do
    it 'fetch vertex names correctly' do
      script = 'g.V.both.groupCount.cap.orderMap(T.decr)[0..1].name'

      expect( g.q(script) ).to have(2).items
    end

    it 'fetch paths correctly' do
      script = "g.v(#{@v1.id}).out.path{it.name}{it.name}"

      expect( g.q(script) ).to eq [['marko','vadas'], ['marko','josh'], ['marko','lop']]
    end

    it 'computes hash results correctly' do
      script = "g.E.has('weight',T.gt,0.5d).outV.transform{[name:it.name,age:it.age]}"

      expect( g.q(script) ).to eq( [{'name'=>'marko','age'=>29},
                                    {'name'=>'josh','age'=>32}] )
    end
  end
end
