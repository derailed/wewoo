require 'spec_helper'
require 'support/graph_sets'

module Wewoo
  describe ResultSet do
    before :all do
      @g = Graph.new( :test_graph )
      build_sample_graph( @g )
    end

    context 'graph elements' do
      let(:rs) { ResultSet.new( @g, {})}

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
      it "hydrates simple response correctly" do
        resp = {"results"=>nil, "success"=>true, "queryTime"=>188.219136}
        rs = ResultSet.new( @g, resp )
        expect( rs.hydrate ).to eq true
      end

      it 'hydrates from a single element array correctly' do
        rs = ResultSet.new( @g, raw = [10] )

        expect( rs.hydrate ).to eq raw
      end

      it 'hydrates from a single vertex correctly' do
        raw = [{'_type' => 'vertex', "name" => 'fred'}]
        rs  = ResultSet.new( @g, raw )

        res = rs.hydrate
        expect( res ).to have(1).item
        expect( res.first.class ).to eq Wewoo::Vertex
      end

      it 'hydrates from a single edge correctly' do
        raw = [
          {'_type' => 'edge', '_id' => 1, "_label" => 'fred', '_outV' => 1, '_inV' => 2}
        ]
        res  = ResultSet.new( @g, raw ).hydrate

        expect( res ).to have(1).item
        expect( res.first.class ).to eq Wewoo::Edge
      end

      it 'hydrates from a multiple graph elements correctly' do
        raw = [
          {'_id'=>1, '_type'=>'vertex', "name"=>'fred'},
          {'_id'=>2, '_type'=>'vertex', "name"=>'blah'},
          {'_id'=>3, '_type'=>'edge'  , '_label'=>'fred', '_outV'=> 1, 'inV'=>2}
        ]

        res = ResultSet.new( @g, raw ).hydrate
        expect( res ).to have(3).items
      end

      it 'hydrates a regular hash correctly' do
        raw = [{"marko"=>1, "peter"=>1, "josh"=>2}]
        res = ResultSet.new( @g, raw ).hydrate

        expect( res ).to have(3).items
      end

      it 'hydrates collection maps correctly' do
        raw = [{
          "109068"=>{
            "_value"=>1,
            "_key"  =>{"name"=>"ripple", "gid"=>109068, "lang"=>"java", "_id"=>109068, "_type"=>"vertex"}
          },
          "109060"=>{
            "_value"=>3,
            "_key"  =>{"name"=>"lop", "gid"=>109060, "lang"=>"java", "_id"=>109060, "_type"=>"vertex"}
          },
          "109056"=>{
            "_value"=>1,
            "_key"  =>{"age"=>27, "name"=>"vadas", "gid"=>109056, "_id"=>109056, "_type"=>"vertex"}
          },
          "109064"=>{
            "_value"=>1,
            "_key"=>{"age"=>32, "name"=>"josh", "gid"=>109064, "_id"=>109064, "_type"=>"vertex"}
          }
        }]

        # raw = [[
        #  {
        #    '_key'   => {'_id' => 1, '_type' => 'vertex', "name" => 'fred'},
        #    '_value' => 10
        #  }
        # ]]


        res = ResultSet.new( @g, raw ).hydrate
        expect( res ).to have(4).items
        expect( res.is_a? Hash ).to be_true
        expect( res.values ).to eq [1,3,1,1]
        expect( res.keys.map(&:id)).to eq [109068, 109060, 109056, 109064]
      end

      it 'hydrates a collection of tuples correctly' do
        raw = [
          [
            {"age"=>29, "name"=>"marko", "gid"=>110668, "_id"=>110668, "_type"=>"vertex"},
            {"age"=>27, "name"=>"vadas", "gid"=>110672, "_id"=>110672, "_type"=>"vertex"}
          ],
          [
            {"age"=>29, "name"=>"marko", "gid"=>110668, "_id"=>110668, "_type"=>"vertex"},
            {"age"=>32, "name"=>"josh", "gid"=>110680, "_id"=>110680, "_type"=>"vertex"}
          ],
          [
            {"age"=>29, "name"=>"marko", "gid"=>110668, "_id"=>110668, "_type"=>"vertex"},
            {"name"=>"lop", "gid"=>110676, "lang"=>"java", "_id"=>110676, "_type"=>"vertex"}
          ]
        ]

        res = ResultSet.new( @g, raw ).hydrate
        expect( res ).to have(3).items
        expect( res.first ).to have(2).items
      end

      it 'hydrate a values collection correctly' do
        raw = [
          {
            "111552"=> {
              "_value"=>[ {"name"=>"lop", "gid"=>111540, "lang"=>"java", "_id"=>111540, "_type"=>"vertex"}],
              "_key"=>{"age"=>35, "name"=>"peter", "gid"=>111552, "_id"=>111552, "_type"=>"vertex"}
            },
            "111540"=>{
              "_value"=>[],
              "_key"=>{"name"=>"lop", "gid"=>111540, "lang"=>"java", "_id"=>111540, "_type"=>"vertex"}
            },
            "111536"=>{
              "_value"=>[],
              "_key"=>{"age"=>27, "name"=>"vadas", "gid"=>111536, "_id"=>111536, "_type"=>"vertex"}
            },
            "111548"=>{
              "_value"=>[],
              "_key"=>{"name"=>"ripple", "gid"=>111548, "lang"=>"java", "_id"=>111548, "_type"=>"vertex"}
            },
            "111532"=>{
              "_value"=>[
                {"age"=>27, "name"=>"vadas", "gid"=>111536, "_id"=>111536, "_type"=>"vertex"},
                {"age"=>32, "name"=>"josh", "gid"=>111544, "_id"=>111544, "_type"=>"vertex"},
                {"name"=>"lop", "gid"=>111540, "lang"=>"java", "_id"=>111540, "_type"=>"vertex"}
              ],
              "_key"=>{"age"=>29, "name"=>"marko", "gid"=>111532, "_id"=>111532, "_type"=>"vertex"}
            },
            "111544"=>{"_value"=>[
              {"name"=>"ripple", "gid"=>111548, "lang"=>"java", "_id"=>111548, "_type"=>"vertex"},
              {"name"=>"lop", "gid"=>111540, "lang"=>"java", "_id"=>111540, "_type"=>"vertex"}
              ],
              "_key"=>{"age"=>32, "name"=>"josh", "gid"=>111544, "_id"=>111544, "_type"=>"vertex"}
            }
        }]

        res = ResultSet.new( @g, raw ).hydrate
        expect( res.is_a? Hash ).to be_true
        expect( res ).to have(6).items
        res.values.each do |v|
          unless v.empty?
            expect( v.first.is_a? Wewoo::Vertex ).to be_true
          end
        end
      end
    end

    context 'Vertex' do
      it 'collects vertices correctly' do
        q = "g.v(#{@v1.id}).out"

        expect( @g.q(q) ).to eq [@v2, @v4, @v3]
      end

      it 'fetch a single vertex correctly' do
        expect( @g.q("g.v(#{@v1.id})") ).to eq [@v1]
      end
    end

    context 'Edge' do
      it 'collects edges correctly' do
        expect( @g.q("g.v(#{@v1.id}).outE") ).to eq [@e7, @e8, @e9]
      end

      it 'fetch a single edge correctly' do
        expect( @g.q("g.e('#{@e8.id}')") ).to eq [@e8]
      end
    end

    context 'Others' do
      it 'count' do
        q = "g.V.count()"

        expect( @g.q( q ) ).to eq [6]
      end
    end
  end
end
