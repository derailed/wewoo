require 'spec_helper'
require 'support/graph_sets'

module Wewoo
  describe ResultSet do
    let(:g) { Graph.new( :test_graph ) }

    before :each do
      build_sample_graph( g )
    end

    context 'graph elements' do
      let(:rs) { ResultSet.new( g, {})}

      it 'check for graph element correctly' do
        expect( rs.graph_element?( {'_type' => "vertex"} ) ).to eq true
      end

      context '#build_element' do
        it 'builds a vertex correctly' do
          v = rs.build_element( {'_type' => 'vertex',
                                 'age'   => 20,
                                 'name'  => 'fred' } )

          expect( v.props.name ).to eq 'fred'
          expect( v.props.age ).to  eq 20
        end

        it 'builds an edge correctly' do
          e = rs.build_element( {'_type'  => 'edge',
                                 '_label' => 'fred',
                                 'age'    => 20 } )

          expect( e.label ).to     eq 'fred'
          expect( e.props.age ).to eq 20
        end

        it 'fails if no graph element is detected' do
          expect{ rs.build_element({'_type'=>'vertexo'})}.to raise_error
        end
      end
    end

    context '#hydrate' do
      it "hydrates from a hash correctly" do
        raw = { blee: 'duh' }
        rs = ResultSet.new( g, raw )
        expect( rs.hydrate ).to eq raw
      end

      it 'hydrates from a single element array correctly' do
        raw = [10]
        rs  = ResultSet.new( g, raw )
        expect( rs.hydrate ).to eq raw
      end

      it 'hydrates from a single graph element correctly' do
        raw = [{'_type' => 'vertex', "name" => 'fred'}]
        rs  = ResultSet.new( g, raw )
        expect( rs.hydrate ).to have(1).item
      end

      it 'hydrates from a multiple graph element correctly' do
        raw = [
          {'_id' => 1, '_type' => 'vertex', "name" => 'fred'},
          {'_id' => 2, '_type' => 'vertex', "name" => 'blah'},
          {'_id' => 3,
           '_type'  => 'edge'  ,
           '_label' => 'fred',
           '_outV'  => 1,
           'inV'    => 2 }
        ]
        rs = ResultSet.new( g, raw )
        expect( rs.hydrate ).to have(3).items
      end

      it 'hydrates count maps correctly' do
        raw = [[
          {'_key'   => {'_id' => 1, '_type' => 'vertex', "name" => 'fred'},
           '_value' => 10}
        ]]
        rs  = ResultSet.new( g, raw )

        expect( rs.hydrate ).to have(1).items
      end
    end

    context 'Vertex' do
      it 'collects vertices correctly' do
        expect( g.q("g.v(#{@v1.id}).out") ).to eq [@v2, @v4, @v3]
      end

      it 'fetch a single vertex correctly' do
        expect( g.q("g.v(#{@v1.id})") ).to eq [@v1]
      end
    end

    context 'Edge' do
      it 'collects edges correctly' do
        expect( g.q("g.v(#{@v1.id}).outE") ).to eq [@e7, @e8, @e9]
      end

      it 'fetch a single edge correctly' do
        expect( g.q("g.e('#{@e8.id}')") ).to eq [@e8]
      end
    end

    context 'Non Elements' do
      it 'fetch vertex names correctly' do
        script = 'g.V.both.groupCount.cap.orderMap(T.decr)[0..1].name'

        expect( g.q(script) ).to have(2).items
      end

      it 'fetch paths correctly' do
        script = "g.v(#{@v1.id}).out.path{it.name}{it.name}"

        expect( g.q(script) ).to eq [['marko','vadas'], ['marko','josh'], ['marko','lop']]
      end

      it 'computes hash results correctly' do
        script = "g.E.has('weight',T.gt,0.5d).outV.transform{[name:it.name,age:it.age]}"

        expect( g.q(script).sort{ |a,b| a['name'] <=> b['name']} ).to eq(
          [{'name'=>'josh','age'=>32}, {'name'=>'marko','age'=>29}] )
      end
    end
  end
end
