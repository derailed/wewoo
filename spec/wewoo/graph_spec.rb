require 'spec_helper'

module Wewoo
  describe Graph do
    let(:graph) { Graph.new( :test_graph ) }

    before :each do
      graph.clear
    end

    it "show all available graphs" do
      graphs = Graph.available_graphs

      expect( graphs ).to_not be_empty
    end

    it 'opens a graph correctly' do
      expect( graph.vertices ).to be_empty
      expect( graph.edges ).to be_empty
    end

    it 'errors out if a graph does not exist' do
      expect{ Graph.new( :test_yo ) }.to raise_error
    end

    pending 'list available indexes correctly' do
      expect( graph.key_indices.vertex).to be_empty
      expect( graph.key_indices.edge).to be_empty

      graph.set_key_index( :vertex, :fred )
      expect( graph.key_indices.vertex ).to have(1).item
      #graph.drop_key_index( type: :vertex, :fred )
    end

    context 'Query' do
      let(:v1)     { graph.add_vertex( id:1, name:'fred', age:20 ) }
      let(:v2)     { graph.add_vertex( id:2, name:'joe' , age:30 ) }
      let(:v3)     { graph.add_vertex( id:3, name:'max' , age:40 ) }
      let(:v4)     { graph.add_vertex( id:4, name:'blee', age:50 ) }
      let!(:e_1_2) { graph.add_edge( v1.gid, v2.gid, :friend, id:1 ) } 
      let!(:e_1_3) { graph.add_edge( v1.gid, v3.gid, :friend, id:2 ) } 
      let!(:e_2_3) { graph.add_edge( v2.gid, v3.gid, :friend, id:3 ) } 
      let!(:e_3_4) { graph.add_edge( v3.gid, v4.gid, :friend, id:4 ) } 

      it 'retrieves frienships correctly' do
        edges = graph.query( "g.v(1).outE('friend')" )

        expect( edges ).to        have(2).items
        expect( edges.first ).to  eq e_1_3
        expect( edges.last ).to   eq e_1_2
      end

      it 'retrieves friends correctly' do
        vertices = graph.query( "g.v(1).out('friend')" )

        expect( vertices ).to       have(2).items
        expect( vertices.first ).to eq v3
        expect( vertices.last ).to  eq v2
      end

      it 'retrieves friends of friends correctly' do
        vertices = graph.query( "g.v(1).out('friend').out('friend')" )

        expect( vertices ).to       have(2).items
        expect( vertices.first ).to eq v4
        expect( vertices.last ).to  eq v3
      end
      
      it "paginates results correctly" do
        vertices = graph.query( "g.V", page:1, per_page:2 )
        expect( vertices ).to have(2).items
      end
    end

    context 'Vertices' do
      let!(:v1) { graph.add_vertex( id:1, name:'fred', age:20 ) }

      it 'creates a vertex correctly' do
        vertices = graph.vertices

        expect( vertices ).to have(1).item
        expect( vertices.first.class ).to eq Vertex
        expect( vertices.first.properties.age ).to eq '20'
        expect( vertices.first.properties.name ).to eq 'fred'
      end
     
      context 'find' do
        it 'finds a node by id correctly' do
          vertex = graph.get_vertex( v1.gid )
          
          expect( vertex ).to_not be_nil
          expect( vertex ).to eq  v1
        end

        it 'finds a node by properties correctly' do
          candidates = graph.get_vertices( :name, :fred )
          
          expect( candidates ).to_not   be_nil
          expect( candidates.first ).to eq v1
        end
      end

      it 'updates a node correctly' do
        graph.add_vertex( id:v1.gid, age:18 )

        expect( graph.vertices ).to have(1).item
        expect( graph.vertices.first.properties.age ).to eq '18'
      end

      it 'deletes a node correctly' do
        expect( graph.vertices ).to have(1).item

        graph.remove_vertex( v1.gid )

        expect( graph.vertices ).to be_empty
      end

      context 'connected' do
        let!(:v2) { graph.add_vertex( id:2, name:'blee', age:50 ) }
        let!(:e1) { graph.add_edge( v1.gid, v2.gid, :friend, id:1 ) } 

        it 'deletes an origin node correctly' do
          graph.remove_vertex( v1.gid )

          expect( graph.edges ).to be_empty
          expect( graph.vertices ).to have(1).item
        end

        it 'deletes an destination node correctly' do
          graph.remove_vertex( v2.gid )

          expect( graph.edges ).to be_empty
          expect( graph.vertices ).to have(1).item
        end
      end
    end

    context 'Edges' do
      let!(:v1) { graph.add_vertex( id:1, name:'blee', age:25 ) }
      let!(:v2) { graph.add_vertex( id:2, name:'fred', age:30 ) }
      let!(:e1) { graph.add_edge( v1.gid, v2.gid, :friend,
                                  id: 1, group: :derailed, city: :denver ) } 

      it 'creates an edge correctly' do
        expect( graph.edges ).to have(1).item
        edge = graph.edges.first
        expect( edge.class ).to            eq Edge
        expect( edge.gid ).to              eq "1"
        expect( edge.label ).to            eq 'friend'
        expect( edge.from_gid ).to         eq v1.gid
        expect( edge.to_gid ).to           eq v2.gid
        expect( edge.properties.group ).to eq 'derailed'
        expect( edge.properties.city ).to  eq 'denver'
      end

      context 'find' do
       it 'find an edge by id correctly' do
        edge = graph.get_edge( e1.gid )

        expect( edge ).to eq e1
       end

       it 'find an edge by property correctly' do
        edges = graph.get_edges( :group, :derailed )

        expect( edges.first ).to eq e1
       end
      end

      it 'deletes an edge correctly' do
        graph.remove_edge( e1.gid )

        expect( graph.edges ).to be_empty
        expect( graph.vertices ).to have(2).items 
      end
    end
  end
end
