require "spec_helper"

describe Lita::Handlers::Cricket, lita_handler: true do
  it {is_expected.to route('cricket').to(:scores)}
  it {is_expected.to route('do youses like cricket?').to(:refresh_user)}
  it {is_expected.to route('cricket -s 743965').to(:subscribe)}
  it {is_expected.to route('cricket -u 743963').to(:unsubscribe)}
  it {is_expected.to route('cricket -l').to(:list)}
  it {is_expected.to route('cricket -f Cromer Cricket Club').to(:favourite)}
  before{robot.trigger(:loaded)}

  it 'welcomes you if you have never mentioned cricket before' do
    send_message('do youses all want to go to the cricket on sunday?')
    expect(replies.first).to eq('I can give you live cricket updates! Type `help cricket` for more information.')
  end

  it 'subscribes you to matches featuring your favourite teams if you mention cricket' do
    send_message('this is the first time i have mentioned cricket')
    send_message('cricket')
    #TODO: find out how we can test that nothing crapped out...
  end

  it 'displays the current live matches' do
    send_message('cricket -l')
    expect(replies.last).to start_with('some_information_from_the_api')
  end

end
