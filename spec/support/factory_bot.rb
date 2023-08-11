RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.definition_file_paths = %w{./factories ./test/factories ./spec/factories}
    FactoryBot.find_definitions
  end
end
