def build_test_graph( g )
  g.clear

  @v1 = g.add_vertex( gid: 1  , name:'fred', age:20, rating: 30.5, busy: true )
  @v2 = g.add_vertex( gid: 2  , name:'joe' , age:30, rating: 20.5, busy: false )
  @v3 = g.add_vertex( gid: 3  , name:'max' , age:40, rating: 10.5, busy: true )
  @v4 = g.add_vertex( gid: "4", name:'blee', age:50, rating: 5.5 , busy: true )

  @e1 = g.add_edge( @v1, @v2, :friend )
  @e2 = g.add_edge( @v1, @v3, :friend )
  @e3 = g.add_edge( @v1, @v4, :love   )
  @e4 = g.add_edge( @v2, @v3, :friend )
  @e5 = g.add_edge( @v3, @v4, :friend )
end

def build_sample_graph( g )
  g.clear
  #g.ensure_index(:name,:vertex)

  @v1 = g.add_vertex( name: :marko , age: 29 )
  @v2 = g.add_vertex( name: :vadas , age: 27 )
  @v3 = g.add_vertex( name: :lop   , lang: :java )
  @v4 = g.add_vertex( name: :josh  , age: 32 )
  @v5 = g.add_vertex( name: :ripple, lang: :java )
  @v6 = g.add_vertex( name: :peter , age: 35 )

  @e7 =  g.add_edge( @v1, @v2, :knows  , weight: 0.5 )
  @e8 =  g.add_edge( @v1, @v4, :knows  , weight: 1.0 )
  @e9 =  g.add_edge( @v1, @v3, :created, weight: 0.4 )
  @e10 = g.add_edge( @v4, @v5, :created, weight: 1.0 )
  @e11 = g.add_edge( @v4, @v3, :created, weight: 0.4 )
  @e12 = g.add_edge( @v6, @v3, :created, weight: 0.2 )
end
