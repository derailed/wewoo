guard 'bundler' do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end

guard 'rspec', cli: "--color --format Fuubar --fail-fast --drb", all_after_pass: false, all_on_start: false do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/wewoo/**/(.+)\.rb$})     { |m| "spec/wewoo/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
