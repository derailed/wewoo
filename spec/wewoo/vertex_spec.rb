require 'spec_helper'

module Wewoo
  describe Vertex do
    let(:g) { Graph.new( :test_graph ) }

    before :each do
      g.clear
    end

    context 'connections' do
      let!(:v1)   { g.add_vertex( name: :fred, age:10 ) }
      let!(:v2)   { g.add_vertex( name: :blee, age:20 ) }
      let!(:v3)   { g.add_vertex( name: :bob , age:30 ) }
      let!(:e1_2) { g.add_edge( v1, v2, :friend ) }
      let!(:e1_3) { g.add_edge( v1, v3, :bobo   ) }
      let!(:e2_3) { g.add_edge( v2, v3, :zob    ) }

      context "edges" do
        it "fetches out edges correctly" do
          expect( v1.outE ).to eq [e1_2, e1_3]
          expect( v2.outE ).to eq [e2_3]
        end

        it "fetches in edges correctly" do
          expect( v1.inE ).to have(0).items
          expect( v2.inE ).to eq [e1_2]
        end

        it "fetches both edges correctly" do
           expect( v1.bothE ).to eq [e1_2,e1_3]
        end

        it 'fetches both names edges correctly' do
          expect( v1.bothE(:friend, :bobo) ).to eq [e1_2, e1_3]
        end

        it 'fetches out labeled edges correctly' do
          expect( v1.outE(:friend,:bobo) ).to have(2).items
        end

        it 'fetches in labeled edges correctly' do
          expect( v1.inE(:friend,:bobo) ).to be_empty
        end
      end

      context "vertices" do
        it "retrieves out vertices correctly" do
          expect( v1.out ).to eq [v2,v3]
          expect( v2.out ).to eq [v3]
        end

        it "fetches in edges correctly" do
          expect( v1.in ).to have(0).items
          expect( v2.in ).to eq [v1]
        end

        it "fetches on label correctly" do
          expect( v2.in( :friend ) ).to  eq [v1]
          expect( v3.in( :bobo ) ).to    eq [v1]
          expect( v1.out( :bobo ) ).to   eq [v3]
          expect( v1.out( :friend ) ).to eq [v2]
        end

        it "fetches all vertex correctly" do
          expect( v2.both ).to       eq [v1,v3]
          expect( v2.both(:zob) ).to eq [v3]
        end


        it "Deletes a vertex correctly" do
          t_v = g.V.count
          t_e = g.E.count
          v1.destroy

          expect( g.V.count ).to eq t_v-1
          expect( g.E.count ).to eq t_e-2
        end
      end
    end
  end
end
