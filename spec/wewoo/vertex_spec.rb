require 'spec_helper'

module Wewoo
  describe Edge do
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

      context "edges" do
        it "fetches out edges correctly" do
          edges = v1.outE

          expect( edges ).to have(2).items
          expect( edges.first ).to eq e1_3
          expect( edges.last ).to  eq e1_2

          expect( v2.outE ).to have(0).items
        end

        it "fetches in edges correctly" do
          expect( v1.inE ).to have(0).items

          edges = v2.inE
          expect( edges ).to have(1).items
          expect( edges.first ).to eq e1_2
        end
      end
 
      context "vertices" do
        it "fetches out vertices correctly" do
          vertices = v1.out

          expect( vertices ).to have(2).items
          expect( vertices.first ).to eq v3
          expect( vertices.last ).to  eq v2

          expect( v2.out ).to have(0).items
        end

        it "fetches in edges correctly" do
          expect( v1.in ).to have(0).items

          vertices = v2.in
          expect( vertices ).to have(1).items
          expect( vertices.first ).to eq v1
        end
      end
    end
  end
end
