require 'spec_helper'

module Wewoo
  describe Graph do
    before :all do
      @g = Graph.new( :test_graph )
      build_test_graph( @g )
    end

    context "Graphs" do
      it "show all available graphs" do
        expect( Graph.available_graphs ).to_not be_empty
      end

      it 'opens a graph correctly' do
        expect( @g.V ).to have(4).items
        expect( @g.E ).to have(5).items
      end

      it 'errors out if a graph does not exist' do
        expect{ Graph.new( :test_yo ) }.to raise_error
      end
    end

    context 'Query' do
      it 'retrieves frienships correctly' do
        edges = @g.query( "g.v(#{@v1.id}).outE('friend')" )

        expect( edges ).to    have(2).items
        expect( edges ).to eq [@e1, @e2]
      end

      it 'retrieves friends correctly' do
        vertices = @g.query( "g.v(#{@v1.id}).out('friend')" )

        expect( vertices ).to    have(2).items
        expect( vertices ).to eq [@v2, @v3]
      end

      it 'retrieves friends of friends correctly' do
        vertices = @g.query( "g.v(#{@v1.id}).out('friend').out('friend')" )

        expect( vertices ).to    have(2).items
        expect( vertices ).to eq [@v3, @v4]
      end

      it "paginates results correctly" do
        vertices = @g.query( "g.V", page:1, per_page:2 )

        expect( vertices ).to have(2).items
      end
    end

    context 'Vertex' do
      it 'checks for vertex existance correctly' do
        v1 = @g.find_first_vertex( :gid, 1 )

        expect( @g.vertex_exists?( v1.id ) ).to eq true
        expect( @g.vertex_exists?( 1234 ) ).to  eq false
      end

      it 'creates a vertex correctly' do
        v  = @g.add_vertex( name:'test', age:20, gid: 100 )
        vg = @g.find_vertex( v.id )

        expect( vg ).to_not        be_nil
        expect( vg.props.age ).to  eq 20
        expect( vg.props.name ).to eq 'test'
      end

      it 'updates a vertex correctly' do
        v       = @g.find_first_vertex( :gid, 100 )
        v_prime = @g.update_vertex( v.id, age: 30, blee:'testola', weight: 160.5 )

        expect( v_prime ).to_not          be_nil
        expect( v_prime.props.weight ).to eq 160.5
        expect( v_prime.props.name ).to   eq 'test'
        expect( v_prime.props.blee ).to   eq 'testola'
        expect( v_prime.gid ).to          eq 100
        expect( v_prime.props.age ).to    eq 30
      end

      context 'mine types' do
        it 'coerve floats correctly' do
          v = @g.add_vertex( weight: 18.5 )

          expect( v.props.weight ).to eq 18.5
        end

        it 'coerce integer correctly' do
          v = @g.add_vertex( age: 30 )

          expect( v.props.age ).to eq 30
        end

        it 'coerce boolean correctly' do
          v = @g.add_vertex( dead: false )

          expect( v.props.dead ).to eq false
        end

        it 'coerce array correctly' do
          v = @g.add_vertex( blees: [1,2,3] )

          expect( v.props.blees ).to eq [1,2,3]
        end

        it 'coerce hash correctly' do
          hash = {a:1,b:2,c:3}
          v    = @g.add_vertex( blees: hash )

          expect( v.properties.blees ).to eq hash
        end

        it 'coerce complex types correctly' do
          hash = {a:[1,2,3],b:2.0,c:3}
          v    = @g.add_vertex( blees: hash )

          expect( v.properties.blees ).to eq hash
        end
      end

      context 'finders' do
        it 'finds a vertex by id correctly' do
          expect( @g.find_vertex( @v1.id ) ).to eq @v1
        end

        it 'finds a vertex by gid correctly' do
          expect( @g.find_vertex_by_gid( @v1.gid ) ).to eq @v1
        end

        it 'finds the first vertex matching a prop' do
          expect( @g.find_first_vertex( :name, 'fred' ) ).to eq @v1
        end

        it 'finds the first vertex matching a an int prop' do
          expect( @g.find_first_vertex( :age, 50 ) ).to eq @v4
        end

        it 'finds the first vertex matching a a float prop' do
          expect( @g.find_first_vertex( :rating, 5.5 ) ).to eq @v4
        end

        it 'finds the first vertex matching a boolean prop' do
          expect( @g.find_first_vertex( :busy, false ) ).to eq @v2
        end
      end
    end
    #   context 'deletes' do
    #     it 'deletes a node correctly' do
    #       v1 = g.add_vertex( age:18 )
    #       expect( g.vertices ).to have(1).item
    #
    #       g.remove_vertex( v1.id )
    #
    #       expect( g.V ).to be_empty
    #     end
    #   end
    #
    #   context 'connected' do
    #     let!(:v2) { g.add_vertex( name:'blee', age:50 ) }
    #     let!(:e1) { g.add_edge( v1.id, v2.id, :friend ) }
    #
    #     it 'deletes an origin node correctly' do
    #       g.remove_vertex( v1.id )
    #
    #       expect( g.E ).to be_empty
    #       expect( g.V ).to have(1).item
    #     end
    #
    #     it 'deletes an destination node correctly' do
    #       g.remove_vertex( v2.id )
    #
    #       expect( g.E ).to be_empty
    #       expect( g.V ).to have(1).item
    #     end
    #   end
    # end

    context 'Edge' do
      it 'checks for edge existance correctly' do
        expect( @g.edge_exists?( @e1.id ) ).to eq true
        expect( @g.edge_exists?( 1234 ) ).to  eq false
      end

      it 'creates an edge correctly' do
        e6   = @g.add_edge( @v1, @v2, :test, city: "Denver", state: "CO")
        edge = @g.find_edge( e6.id )

        expect( edge.label ).to       eq 'test'
        expect( edge.from_id ).to     eq @v1.id
        expect( edge.to_id ).to       eq @v2.id
        expect( edge.props.city ).to  eq 'Denver'
        expect( edge.props.state ).to eq 'CO'
      end

      it 'updates an edge correctly' do
        e       = @g.find_first_edge( :state, "CO" )
        e_prime = @g.update_edge( e.id, name: :testola, approved: true )

        expect( e_prime ).to_not            be_nil
        expect( e_prime.props.name ).to     eq 'testola'
        expect( e_prime.props.approved ).to eq true
        expect( e_prime.props.city ).to     eq "Denver"
      end

      it 'deletes an edge correctly' do
        e = @g.find_first_edge( :city, "Denver" )
        @g.remove_edge( e.id )

        lambda{ @g.e( e.id ) }.should raise_error Graph::GraphElementNotFoundError
      end

      context 'find' do
        it 'find an edge by id correctly' do
         edge = @g.e( @e1.id )

         expect( edge ).to eq @e1
        end

        it 'find first edge by property correctly' do
         edge = @g.find_first_edge( :rating, 2.5 )

         expect( edge ).to eq @e2
        end

        it 'find an edge by property correctly' do
         edges = @g.find_edges( :rating, 5.5 )

         expect( edges ).to have(2).items
        end
      end
    end
  end
end
