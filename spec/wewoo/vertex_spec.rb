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
      let!(:e1_3) { graph.add_edge( 1, 3, :bobo  , id:2 ) }
      let!(:e2_3) { graph.add_edge( 2, 3, :zob   , id:3 ) }

      context "edges" do
        it "fetches out edges correctly" do
          edges = v1.outE

          expect( edges ).to have(2).items
          expect( edges.first ).to eq e1_3
          expect( edges.last ).to  eq e1_2

          expect( v2.outE ).to have(1).items
        end

        it "fetches in edges correctly" do
          expect( v1.inE ).to have(0).items

          edges = v2.inE
          expect( edges ).to have(1).item
          expect( edges.first ).to eq e1_2
        end

        it "fetches both edges correctly" do
           edges = v1.bothE

           expect( edges ).to have(2).item
           expect( edges ).to eq [e1_3,e1_2]
        end
      end

      context "vertices" do
        it "fetches out vertices correctly" do
          vertices = v1.out
          expect( vertices ).to have(2).items
          expect( vertices.first ).to eq v3
          expect( vertices.last ).to  eq v2

          expect( v2.out ).to have(1).items
        end

        it "fetches in edges correctly" do
          expect( v1.in ).to have(0).items

          vertices = v2.in
          expect( vertices ).to have(1).items
          expect( vertices.first ).to eq v1
        end

        it "fetches on label correctly" do
          expect( v2.in( [:friend] ) ).to  eq [v1]
          expect( v3.in( [:bobo] ) ).to    eq [v1]
          expect( v1.out( [:bobo] ) ).to   eq [v3]
          expect( v1.out( [:friend] ) ).to eq [v2]
        end

        it "fetches all vertex correctly" do
          expect( v2.both ).to         eq [v1,v3]
          expect( v2.both([:zob]) ).to eq [v3]
        end
      end
    end
  end
end
