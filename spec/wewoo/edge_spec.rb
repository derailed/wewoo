require 'spec_helper'

module Wewoo
  describe Vertex do
    let(:g) { Graph.new(:test_graph) }
    before :all do
      build_test_graph( g )
    end

    context 'equality' do
      it 'validates two egdes are the same' do
        expect( @v1.outE(:love) == @v1.outE(:love) ).to eq true
      end

      it 'validates two egdes are different' do
        e1, e2 = @v1.outE(:friend).first, @v1.outE(:friend).last

        expect( e1 == e2 ).to eq false
      end

      it 'validates anything against null' do
        expect( @v1.outE(:love) == nil ).to be false
      end
    end

    context 'vertices' do
      it "fetches edge head correctly" do
        expect( @e1.in ).to eq @v2
      end

      it "fetches edge tail correctly" do
        expect( @e1.out ).to eq @v1
      end

      it 'deletes an edge correctly' do
        before = g.E.count()
        @e1.destroy

        expect( g.E.count() ).to eq before-1
      end
    end
  end
end
