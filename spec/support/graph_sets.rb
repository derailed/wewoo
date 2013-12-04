def build_test_graph( graph )
  v1 = graph.add_vertex( id:1, name:'fred', age:20 )
  v2 = graph.add_vertex( id:2, name:'joe' , age:30 )
  v3 = graph.add_vertex( id:3, name:'max' , age:40 )
  v4 = graph.add_vertex( id:4, name:'blee', age:50 )

  edges = []
  edges << graph.add_edge( v1, v2, :friend, id:1 )
  edges << graph.add_edge( v1, v3, :friend, id:2 )
  edges << graph.add_edge( v2, v3, :friend, id:3 )
  edges << graph.add_edge( v3, v4, :friend, id:4 )
  edges << graph.add_edge( v1, v4, :love  , id:5 )

  return [v1,v2,v3,v4], edges
end

def build_sample_graph( g )
  @v1 = g.add_vertex( id:1, name: :marko, age: 29 )
  @v2 = g.add_vertex( id:2, name: :vadas, age: 27 )
  @v3 = g.add_vertex( id:3, name: :lop, lang: :java )
  @v4 = g.add_vertex( id:4, name: :josh, age: 32 )
  @v5 = g.add_vertex( id:5, name: :ripple, lang: :java )
  @v6 = g.add_vertex( id:6, name: :peter, age: 35 )

  @e7 =  g.add_edge( @v1, @v2, :knows, id:7, weight: 0.5 )
  @e8 =  g.add_edge( @v1, @v4, :knows, id:8, weight: 1.0 )
  @e9 =  g.add_edge( @v1, @v3, :created, id:9, weight: 0.4 )
  @e10 = g.add_edge( @v4, @v5, :created, id:10, weight: 1.0 )
  @e11 = g.add_edge( @v4, @v3, :created, id:11, weight: 0.4 )
  @e12 = g.add_edge( @v6, @v3, :created, id:12, weight: 0.2 )
end
