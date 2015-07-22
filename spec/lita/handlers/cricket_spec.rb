require "spec_helper"

describe Lita::Handlers::Cricket, lita_handler: true do
  it {is_expected.to route('cricket').to(:scores)}
  it {is_expected.to route('do youses like cricket?').to(:refresh_user)}
  it {is_expected.to route('cricket -s 743965').to(:subscribe)}
  it {is_expected.to route('cricket -u 743963').to(:unsubscribe)}
  it {is_expected.to route('cricket -l').to(:list)}
  it {is_expected.to route('cricket -f Cromer Cricket Club').to(:favourite)}
  it {is_expected.to route('cricket -r Cromer Cricket Club').to(:unfavourite)}
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
    expect(replies.detect{|x| ( x =~/There are/ ) == 0}).to start_with('There are')
  end

  it 'subscribes/unsubscribes you to some match if you like' do
    send_message('cricket -s 743965')
    expect(replies.last).to eq('Subscribed you to match #743965: OK')
    send_message('cricket -s 743963')
    expect(replies.last).to eq('Subscribed you to match #743963: OK')
    send_message('cricket -u 743963')
    expect(replies.last).to eq('Unsubscribed you to match #743963: OK')
    send_message('cricket -u 743964')
    expect(replies.last).to eq('You weren\'t subscribed to match #743964!')
  end

  it 'displays scores for your cricket matches' do
  end

  it 'lists the matches to which you are subscribed' do
  end

  it 'adds a favourite team' do
  end

  it 'removes a favourite team' do
  end

end
