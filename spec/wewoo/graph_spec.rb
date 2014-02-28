require 'spec_helper'

module Wewoo
  describe Graph do
    let(:g) { Graph.new( :test_graph ) }

    context "Graphs" do
      it "show all available graphs" do
        expect( Graph.available_graphs ).to_not be_empty
      end

      it 'opens a graph correctly' do
        g.clear
        expect( g.V ).to be_empty
        expect( g.E ).to be_empty
      end

      it 'errors out if a graph does not exist' do
        expect{ Graph.new( :test_yo ) }.to raise_error
      end
    end

    context 'Query' do
      before :each do
        g.clear
        build_test_graph( g )
      end

      it 'retrieves frienships correctly' do
        edges = g.query( "g.v(#{@v1.id}).outE('friend')" )

        expect( edges ).to    have(2).items
        expect( edges ).to eq [@e1, @e2]
      end

      it 'retrieves friends correctly' do
        vertices = g.query( "g.v(#{@v1.id}).out('friend')" )

        expect( vertices ).to       have(2).items
        expect( vertices ).to eq    [@v2, @v3]
      end

      it 'retrieves friends of friends correctly' do
        vertices = g.query( "g.v(#{@v1.id}).out('friend').out('friend')" )

        expect( vertices ).to    have(2).items
        expect( vertices ).to eq [@v3, @v4]
      end

      it "paginates results correctly" do
        vertices = g.query( "g.V", page:1, per_page:2 )
        expect( vertices ).to have(2).items
      end
    end

    context 'Vertex' do
      before :each do
        g.clear
      end

      let!(:v1) { g.add_vertex( name:'fred', age:20 ) }

      it 'checks for vertex existance correctly' do
        expect( g.vertex_exists?( v1.id ) ).to eq true
        expect( g.vertex_exists?( 1234 ) ).to  eq false
      end

      it 'creates a vertex correctly' do
        vertices = g.V

        expect( vertices ).to have(1).item
        expect( vertices.first.class ).to eq Vertex
        expect( vertices.first.properties.age ).to eq 20
        expect( vertices.first.properties.name ).to eq 'fred'
      end

      it 'updates a vertex correctly' do
        v_prime = g.update_vertex( v1.id, blee:'duh', weight: 160.5 )

        expect( v_prime ).to_not be_nil
        expect( v_prime.properties.blee ).to  eq 'duh'
        expect( v_prime.properties.weight ).to eq 160.5
        expect( v_prime.properties.exist? :name ).to eq false
        expect( v_prime.properties.exist? :weight ).to eq false
      end

      context 'mine types' do
        it 'coerve floats correctly' do
          v = g.add_vertex( weight: 18.5 )

          expect( v.properties.weight ).to eq 18.5
        end

        it 'coerce integer correctly' do
          v = g.add_vertex( age: 30 )

          expect( v.properties.age ).to eq 30
        end

        it 'coerce boolean correctly' do
          v = g.add_vertex( dead: false )

          expect( v.properties.dead ).to eq false
        end

        it 'coerce array correctly' do
          v = g.add_vertex( blees: [1,2,3] )

          expect( v.properties.blees ).to eq [1,2,3]
        end

        it 'coerce hash correctly' do
          hash = {a:1,b:2,c:3}
          v    = g.add_vertex( blees: hash )

          expect( v.properties.blees ).to eq hash
        end

        it 'coerce complex types correctly' do
          hash = {a:[1,2,3],b:2.0,c:3}
          v    = g.add_vertex( blees: hash )

          expect( v.properties.blees ).to eq hash
        end
      end

      context 'find' do
        before :each do
          g.clear
          build_test_graph( g )
        end

        it 'finds a node by id correctly' do
          vertex = g.get_vertex( @v1.id )

          expect( vertex ).to_not be_nil
          expect( vertex ).to eq  @v1
        end

        it 'finds a node by properties correctly' do
          candidates = g.find_vertices( :name, :fred )

          expect( candidates ).to_not   be_nil
          expect( candidates.first ).to eq @v1
        end
      end

      context 'find' do
        before :each do
          g.clear
        end

        it 'updates a node correctly' do
          g.add_vertex( age:18 )

          expect( g.vertices ).to have(1).item
          expect( g.vertices.first.properties.age ).to eq 18
        end

        it 'deletes a node correctly' do
          v1 = g.add_vertex( age:18 )
          expect( g.vertices ).to have(1).item

          g.remove_vertex( v1.id )

          expect( g.V ).to be_empty
        end
      end

      context 'connected' do
        let!(:v2) { g.add_vertex( name:'blee', age:50 ) }
        let!(:e1) { g.add_edge( v1.id, v2.id, :friend ) }

        it 'deletes an origin node correctly' do
          g.remove_vertex( v1.id )

          expect( g.E ).to be_empty
          expect( g.V ).to have(1).item
        end

        it 'deletes an destination node correctly' do
          g.remove_vertex( v2.id )

          expect( g.E ).to be_empty
          expect( g.V ).to have(1).item
        end
      end
    end

    context 'Edge' do
      before :each do
        g.clear
      end

      let!(:v1) { g.add_vertex( name:'blee', age:25 ) }
      let!(:v2) { g.add_vertex( name:'fred', age:30 ) }
      let!(:e1) { g.add_edge( v1.id, v2.id, :friend,
                              group: :derailed,
                              city: :denver ) }

      it 'checks for edge existance correctly' do
        expect( g.edge_exists?( e1.id ) ).to eq true
        expect( g.edge_exists?( 1234 ) ).to  eq false
      end

      it 'creates an edge correctly' do
        expect( g.E ).to have(1).item

        edge = g.E.first
        expect( edge.class ).to            eq Edge
        expect( edge.label ).to            eq 'friend'
        expect( edge.from_id ).to          eq v1.id
        expect( edge.to_id ).to            eq v2.id
        expect( edge.properties.group ).to eq 'derailed'
        expect( edge.properties.city ).to  eq 'denver'
      end

      it 'updates an edge correctly' do
        e_prime = g.update_edge( e1.id, name: :fred, approved: true )

        expect( e_prime ).to_not                      be_nil
        expect( e_prime.properties.name ).to          eq 'fred'
        expect( e_prime.properties.approved ).to      eq true
        expect( e_prime.properties.exist? :group ).to eq false
      end

      it 'deletes an edge correctly' do
        g.remove_edge( e1.id )

        lambda{ g.e( e1.id ) }.should raise_error Graph::GraphElementNotFoundError
      end

      context 'find' do
        it 'find an edge by id correctly' do
         edge = g.get_edge( e1.id )

         expect( edge ).to eq e1
        end

        it 'find an edge by property correctly' do
         edges = g.find_edges( :group, :derailed )

         expect( edges ).to have(1).item
         expect( edges.first ).to eq e1
        end
      end
    end
  end
end
