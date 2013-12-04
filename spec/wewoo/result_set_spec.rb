require 'spec_helper'
require 'support/graph_sets'

describe Wewoo::ResultSet do
  let!(:g) { Wewoo::Graph.new( :test_graph ) }

  before :each do
    g.clear
    @nodes, @edges = build_sample_graph( g )
  end

  context 'Vertex' do
    it 'collects vertices correctly' do
      expect( g.q('g.v(1).out') ).to eq [@v2, @v4, @v3]
    end

    it 'fetch a single vertex correctly' do
      expect( g.q('g.v(1)') ).to eq @v1
    end
  end

  context 'Edge' do
    it 'collects edges correctly' do
      expect( g.q('g.v(1).outE') ).to eq [@e7, @e8, @e9]
    end

    it 'fetch a single edge correctly' do
      expect( g.q('g.e(8)') ).to eq @e8
    end
  end

  context 'Non Elements' do
    it 'fetch vertex names correctly' do
      script = 'g.V.both.groupCount.cap.orderMap(T.decr)[0..1].name'
      expect( g.q(script) ).to eq %w[lop marko]
    end

    it 'fetch paths correctly' do
      script = 'g.v(1).out.path{it.id}{it.name}'
      expect( g.q(script) ).to eq [['1','vadas'], ['1','josh'], ['1','lop']]
    end

    it 'computes hash results correctly' do
      script = "g.E.has('weight',T.gt,0.5d).outV.transform{[id:it.id,age:it.age]}"
      expect( g.q(script) ).to eq( [{'id'=>'4','age'=>32},
                                    {'id'=>'1','age'=>29}] )
    end
  end
end
