require 'spec_helper'
require 'support/graph_sets'

module Wewoo
  describe 'Gremlin' do
    before :all do
      @g = Graph.new( :test_graph )
      build_sample_graph( @g )
    end

    context 'Transforms' do
      it 'Both' do
        q = "g.v(#{@v4.id}).both('knows','created')"

        expect( @g.q( q ) ).to eq [@v1,@v5,@v3]
      end

      it 'BothE' do
        q = "g.v(#{@v4.id}).bothE('knows','created')"

        expect( @g.q( q ) ).to eq [@e8,@e10,@e11]
      end

      it 'BothV' do
        q = "g.e('#{@e12.id}').bothV"

        expect( @g.q( q ) ).to eq [@v6,@v3]
      end

      it 'Cap' do
        q = "g.V('lang', 'java').in('created').name.groupCount.cap"

        expect( @g.q( q ) ).to eq( {"marko"=>1, "peter"=>1, "josh"=>2} )
      end

      it 'E' do
        q = "g.E.weight"

        expect( @g.q( q ).sort ).to eq [0.2, 0.4, 0.4, 0.5, 1, 1]
      end

      it 'Gather' do
        q = "g.v(#{@v1.id}).out.gather"

        expect( @g.q( q ) ).to eq [@v2,@v4,@v3]
      end

      it "Id" do
        q = "g.v(#{@v1.id}).id"

        expect( @g.q( q ) ).to eq [@v1.id]
      end

      it "In" do
        q = "g.v(#{@v3.id}).in('created')"

        expect( @g.q( q ) ).to eq [@v4, @v1, @v6]
      end

      it "InE" do
        q = "g.v(#{@v3.id}).inE('created')"

        expect( @g.q( q ) ).to eq [@e11, @e9, @e12]
      end

      it "InV" do
        q = "g.e('#{@e12.id}').inV"

        expect( @g.q( q ) ).to eq [@v3]
      end

      it "Out" do
        q = "g.v(#{@v6.id}).out('created')"

        expect( @g.q( q ) ).to eq [@v3]
      end

      it "OutE" do
        q = "g.v(#{@v6.id}).outE('created')"

        expect( @g.q( q ) ).to eq [@e12]
      end

      it "OutV" do
        q = "g.e('#{@e12.id}').outV"

        expect( @g.q( q ) ).to eq [@v6]
      end

      it "Key" do
        q = "g.v(#{@v3.id}).getProperty('name')"

        expect( @g.q( q ) ).to eq ['lop']
      end

      it "Label" do
        q = "g.e('#{@e7.id}').label"

        expect( @g.q( q ) ).to eq ['knows']
      end

      # pending 'LinkBoth'

      it 'Map' do
        q = "g.v('#{@v1.id}').map"

        expect( @g.q( q ) ).to eq( {'age' => 29, 'name' => 'marko', 'gid' => @v1.id} )
      end

      it 'Memoize' do
        q = ["m=[:]"]
        q << "g.V.out.out.memoize(1)"
        q << "g.V.out.out.memoize(1,m).name"

        expect( @g.q( q.join(';') ) ).to eq( ['ripple', 'lop'] )
      end

      it "Order" do
        q = "g.V.name.order{it.b <=> it.a}"

        expect( @g.q( q ) ).to eq %w[vadas ripple peter marko lop josh]
      end

      it "GroupCount" do
        q = "g.V.both.groupCount.cap.orderMap(T.decr)"

        expect( @g.q( q ).sort{ |a,b| a.id <=> b.id } ).to eq [@v1, @v2, @v3, @v4, @v5, @v6]
      end

      it "Path" do
        q = "g.v(#{@v1.id}).out.path"
        expect( @g.q( q ) ).to eq [[@v1, @v2], [@v1, @v4], [@v1, @v3]]

        q = "g.v(#{@v1.id}).out.path{it.name}"
        expect( @g.q( q ) ).to eq [["marko", "vadas"], ["marko", "josh"], ["marko", "lop"]]

        q = "g.v(#{@v1.id}).out.path{it.id}{it.name}"
        expect( @g.q( q ) ).to eq [[@v1.id, "vadas"], [@v1.id, "josh"], [@v1.id, "lop"]]
      end

      it "Scatter" do
        q = "g.v(#{@v1.id}).out.gather{it[1..2]}"
        expect( @g.q( q ) ).to eq [@v4,@v3]

        q = "g.v(#{@v1.id}).out.gather{it[1..2]}.scatter"
        expect( @g.q( q ) ).to eq [@v4,@v3]
      end

      # BOZO!! WTF x:fred ??
      pending "Select", "Don't know to implement this??" do
        q = "g.v(#{@v1.id}).as('x').out('knows').as('y').select"
        expect( @g.q( q ) ).to eq [@v4,@v3]
      end

      it "Shuffle" do
        q = "g.v(#{@v1.id}).out.shuffle"
        expect( @g.q( q ) ).to have(3).items
      end

      it "Transform" do
        q = "g.E.has('weight', T.gt, 0.5f).outV.age.transform{it+2}"
        expect( @g.q( q ).sort ).to eq [31,34]

        q = "g.E.has('weight',T.gt,0.5d).outV.transform{[name:it.name,age:it.age]}"
        expect( @g.q(q).sort{ |a,b| a['name'] <=> b['name']} ).to eq(
        [{'name'=>'josh','age'=>32}, {'name'=>'marko','age'=>29}] )
      end

      it "V" do
        q = "g.V"
        expect( @g.q( q ) ).to have(6).items

        q = "g.V( 'name', 'marko')"
        expect( @g.q( q ) ).to eq [@v1]

        q = "g.V( 'name', 'marko').name"
        expect( @g.q( q ) ).to eq [@v1.props.name]
      end

      it 'fetch vertex names correctly' do
        script = 'g.V.both.groupCount.cap.orderMap(T.decr)[0..1].name'

        expect( @g.q(script) ).to have(2).items
      end
    end

    context "Filter" do
      it '[]' do
        script = 'g.V[0].name'
        expect( @g.q(script) ).to have(1).item
      end

      it '[..]' do
        script = 'g.V[0..2].name'
        expect( @g.q(script) ).to have(3).items
      end

      it 'And' do
        script = 'g.V.and(_().both("knows"), _().both("created"))'
        expect( @g.q(script).sort ).to eq [@v1,@v4]
      end


      it 'Back' do
        script = "g.V.as('x').outE('knows').inV.has('age', T.gt, 30).name.back('x')"
        expect( @g.q(script) ).to eq [@v1]
      end

      it 'Dedup' do
        script = "g.v(#{@v1.id}).out.in.dedup()"
        expect( @g.q(script) ).to eq [@v1, @v4, @v6]
      end

      it 'Except' do
        q = ["x = [g.v(#{@v1.id}), g.v(#{@v2.id}), g.v(#{@v3.id})]"]
        q << "g.V.except(x)"
        expect( @g.q(q.join(";")).sort ).to eq [@v4, @v5, @v6]
      end

      it 'Filter' do
        script = "g.V.filter{it.age > 29}.name"
        expect( @g.q( script ).sort ).to eq %w[josh peter]
      end

      it 'Has' do
        script = "g.v(#{@v1.id}).outE.has('weight', T.gte, 0.5f).weight"
        expect( @g.q( script ).sort ).to eq [0.5, 1.0]
      end

      # BOZO !! No support for full filter ??
      it 'HasNot' do
        script = "g.v(#{@v1.id}).outE.hasNot('name', 'marko').weight"
        expect( @g.q( script ).sort ).to eq [0.4, 0.5, 1.0]
      end

      it 'Interval' do
        script = "g.E.interval('weight', 0.3f, 0.9f).weight"
        expect( @g.q( script ).sort ).to eq [0.4, 0.4, 0.5]
      end

      it 'Or' do
        script = "g.V.or(_().both('knows'), _().both('created'))"
        expect( @g.q( script ).sort ).to eq [@v1, @v2, @v3, @v4, @v5, @v6]
      end

      it 'Random' do
        script = "g.V.random(0.9)"
        expect( @g.q( script ) ).to_not be_empty
      end

      it 'Retain' do
        q = ["x = [g.v(#{@v1.id}), g.v(#{@v2.id}), g.v(#{@v3.id})]"]
        q << 'g.V.retain(x)'
        expect( @g.q( q.join(';') ).sort ).to eq [@v1, @v2, @v3]
      end

      it 'SimplePath' do
        script = "g.v(#{@v1.id}).out.in.simplePath"
        expect( @g.q( script ).sort ).to eq [@v4, @v6]
      end
    end

    context 'Side Effect' do
      it 'Aggregate' do
        script = "x=[];g.v(#{@v1.id}).out.aggregate(x)"
        expect( @g.q( script ).sort ).to eq [@v2,@v3,@v4]
      end

      it 'As' do
        script = "g.V.as('x').outE('knows').inV.has('age', T.gt, 30).back('x').age"
        expect( @g.q( script ).sort ).to eq [29]
      end

      it 'GroupBy' do
        exp = {
          @v1 => [@v2, @v4, @v3],
          @v2 => [],
          @v3 => [],
          @v4 => [@v5,@v3],
          @v5 => [],
          @v6 => [@v3]
        }
        @g.q( "g.V.groupBy{it}{it.out}.cap" ).each_pair { |k,v|
          expect( v ).to eq exp[k]
        }
      end

      it 'GroupCount' do
        exp = {
          @v2 => 1,
          @v4 => 1,
          @v3 => 3,
          @v5 => 1
        }
        q = "x=[:];g.V.out.groupCount(x).cap"
        @g.q( q ).each_pair { |k,v| expect( v ).to eq exp[k] }
      end

      it 'Optional' do
        script = "g.V.as('x').outE('knows').inV.has('age', T.gt, 30).optional('x')"
        expect( @g.q( script ).sort ).to eq [@v1,@v2,@v3,@v4,@v5,@v6]
      end

      pending 'SideEffect' do
        q = ["y = 1000"]
        q << "g.V.has('age').sideEffect{y=y>it.age?it.age:y}"
        q << "y"
        expect( @g.q( q.join(";") ) ).to eq 27
      end

      it 'Store' do
        q = "x=[];g.v(#{@v1.id}).out.store(x).next();x"
        expect( @g.q( q ) ).to eq [@v2]
      end

      pending 'Table' do
        q = "t= new Table();g.V.as('x').name.as('name').back('x').age.as('age').table(t);t"
        expect( @g.q( q ) ).to eq [@v2]
      end

      pending 'Tree'
    end

    context 'Branch' do
      it 'CopySplit'do
        q = "g.v(#{@v1.id}).out('knows').copySplit(_().out('created').name, _().age)"
        expect( @g.q( q ) ).to eq [@v2,@v4]
      end

      it 'ExhaustMerge' do
        q = "g.v(#{@v1.id}).out('knows').copySplit(_().out('created').name, _().age).exhaustMerge"
        expect( @g.q( q ) ).to eq ['ripple', 'lop', 27, 32]
      end

      it 'FairMerge' do
        q = "g.v(#{@v1.id}).out('knows').copySplit(_().out('created').name, _().age).fairMerge"
        expect( @g.q( q ) ).to eq ['ripple', 27, 'lop', 32]
      end

      it 'IfThenElse' do
        q = "g.v(#{@v1.id}).out.ifThenElse{it.name=='josh'}{it.age}{it.name}"
        expect( @g.q( q ) ).to eq ['vadas', 32, 'lop']
      end

      it 'Loop' do
        q = "g.v(#{@v1.id}).out.loop(1){it.loops<3}{it.object.name=='josh'} "
        expect( @g.q( q ) ).to eq [@v4]
      end
    end

    context 'Methods' do
      it 'Keys' do
        q = "g.v(#{@v1.id}).keys()"
        expect( @g.q( q ) ).to eq %w[name age gid]
      end

      it 'Remove' do
        expect( @g.q( "g.E.has('label','test').remove()" ) ).to be true
      end

      it 'Values' do
        q = "g.v(#{@v1.id}).values()"
        expect( @g.q( q ) ).to eq ['marko', 29, @v1.id]
      end

      it 'AddEdge' do
        q = "v1=g.v(#{@v1.id});v2=g.v(#{@v2.id});g.addEdge(v1, v2, 'test')"
        expect( @g.q(q) ).to have(1).item
      end

      it 'RemoveEdge' do
        q = "g.removeEdge( g.E.has('label', 'test').next() )"
        expect( @g.q(q) ).to eq true
      end

      it 'AddVertex' do
        q = "g.addVertex( name: 'Fred' )"
        expect( @g.q(q) ).to have(1).item
      end

      it 'RemoveVertex' do
        q = "g.removeVertex( g.V.has('name', 'Fred').next() )"
        expect( @g.q(q) ).to eq true
      end

      pending 'idx'
      pending 'CreateIndex' do
        q = "g.createIndex('test_index', Vertex.class)"
        expect( @g.q(q) ).to eq []
      end

      it 'e' do
        q = "g.e('#{@e9.id}', '#{@e10.id}', '#{@e11.id}')"
        expect( @g.q( q ) ).to eq [@e9,@e10,@e11]
      end

      it 'v' do
        q = "g.v(#{@v1.id}, #{@v2.id}, #{@v3.id})"
        expect( @g.q( q ) ).to eq [@v1,@v2,@v3]
      end

      it 'EnablePath' do
        q = "g.v(#{@v1.id}).out.loop(1){it.loops < 3}{it.path.contains(g.v(#{@v4.id}))}.enablePath()"
        expect( @g.q(q) ).to eq [@v5,@v3]
      end

      it 'Fill' do
        q = "x=[];g.v(#{@v1.id}).out.fill(x)"
        expect( @g.q(q) ).to eq [@v2,@v4,@v3]
      end

      it 'Iterate' do
        q = "g.V.sideEffect{it.name='same'}.iterate();g.V.name"
        expect( @g.q(q) ).to eq %w[same]*6
      end

      it 'Next' do
        q = "g.V.sideEffect{it.name='same'}.next(3);g.V.name"
        expect( @g.q(q) ).to eq %w[same]*6
      end

      it 'Save' do
        @g.q( "g.saveGraphML('/tmp/graph_test.xml')" )
        expect( File.exists?( '/tmp/graph_test.xml') ).to eq true
      end

      it 'Load' do
        @g.clear
        @g.q( "g.loadGraphML('/tmp/graph_test.xml')")
        expect( @g.V.count ).to eq 6
      end
    end
  end
end
