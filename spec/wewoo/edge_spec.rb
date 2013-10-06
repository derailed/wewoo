require 'spec_helper'

module Wewoo
  describe Vertex do
    let(:graph ) { Graph.new( :test_graph ) }

    before :each do
      graph.clear
    end

    context 'connections' do
      let!(:v1)   { graph.add_vertex( id:1, name: :fred, age:10 ) } 
      let!(:v2)   { graph.add_vertex( id:2, name: :blee, age:20 ) } 
      let!(:v3)   { graph.add_vertex( id:3, name: :bob , age:30 ) } 
      let!(:e1_2) { graph.add_edge( 1, 2, :friend, id:1 ) }
      let!(:e1_3) { graph.add_edge( 1, 3, :friend, id:2 ) }

      it "fetches edge head correctly" do
        expect( e1_2.get_vertex( :in ) ).to eq v1
      end

      it "fetches edge tail correctly" do
        expect( e1_2.get_vertex( :out ) ).to eq v2
      end
    end
  end
end
