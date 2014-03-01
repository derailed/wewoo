require 'spec_helper'

module Wewoo
  describe Vertex do
    before :all do
      @g = Graph.new( :test_graph )
      build_sample_graph( @g )
    end

    context 'connections' do
      context "edges" do
        it "fetches out edges correctly" do
          expect( @v1.outE ).to eq [@e7, @e8, @e9]
          expect( @v2.outE ).to eq []
        end

        it "fetches in edges correctly" do
          expect( @v1.inE ).to eq []
          expect( @v2.inE ).to eq [@e7]
        end

        it "fetches both edges correctly" do
           expect( @v4.bothE ).to eq [@e8,@e10,@e11]
           expect( @v2.bothE ).to eq [@e7]
        end

        it 'fetches both names edges correctly' do
          expect( @v1.bothE(:created, :knows) ).to eq [@e7,@e8,@e9]
        end

        it 'fetches out labeled edges correctly' do
          expect( @v4.outE(:created,:knows) ).to eq [@e10,@e11]
        end

        it 'fetches in labeled edges correctly' do
          expect( @v4.inE(:created,:knows) ).to eq [@e8]
        end
      end

      context "vertices" do
        it "retrieves out vertices correctly" do
          expect( @v1.out ).to eq [@v2,@v4, @v3]
          expect( @v2.out ).to eq []
        end

        it "fetches in edges correctly" do
          expect( @v1.in ).to eq []
          expect( @v2.in ).to eq [@v1]
        end

        it "fetches on label correctly" do
          expect( @v2.in( :knows ) ).to    eq [@v1]
          expect( @v3.in( :knows ) ).to    eq []
          expect( @v1.out( :created ) ).to eq [@v3]
          expect( @v1.out( :knows ) ).to   eq [@v2, @v4]
        end

        it "fetches all vertex correctly" do
          expect( @v2.both ).to       eq [@v1]
          expect( @v2.both(:zob) ).to eq []
        end


        it "Deletes a vertex correctly" do
          t_v = @g.V.count
          t_e = @g.E.count
          @v1.destroy

          expect( @g.V.count ).to eq t_v-1
          expect( @g.E.count ).to eq t_e-3
        end
      end
    end
  end
end
