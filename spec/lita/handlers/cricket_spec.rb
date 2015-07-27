require "spec_helper"

describe Lita::Handlers::Cricket, lita_handler: true do
  it {is_expected.to route('cricket').to(:scores)}
  it {is_expected.to route('do youses like cricket?').to(:refresh_user)}
  it {is_expected.to route('cricket -s 743965').to(:subscribe)}
  it {is_expected.to route('cricket -u 743963').to(:unsubscribe)}
  it {is_expected.to route('cricket -l').to(:list)}
  it {is_expected.to route('cricket -f Cromer Cricket Club').to(:favourite)}
  it {is_expected.to route('cricket -r Cromer Cricket Club').to(:unfavourite)}
  it {is_expected.to route('cricket 743965').to(:score)}
  before{robot.trigger(:loaded)}

  it 'welcomes you if you have never mentioned cricket before' do
    send_message('do youses all want to go to the cricket on sunday?')
    expect(replies.first).to eq('I can give you live cricket updates! Type `help cricket` for more information.')
  end

  it 'displays the current live matches' do
    send_message('cricket -l')
    expect(replies.detect{|x| ( x =~/There are/ ) == 0}.nil?).to eq(false)
  end

  it 'subscribes/unsubscribes you to some match if you like' do
    send_message('cricket -s 743965')
    expect(replies.last).to eq('Subscribed you to match 743965: OK')
    send_message('cricket -s 743963')
    expect(replies.last).to eq('Subscribed you to match 743963: OK')
    send_message('cricket -u 743963')
    expect(replies.last).to eq('Unsubscribed you to match 743963: OK')
    send_message('cricket -u 743964')
    expect(replies.last).to eq('You weren\'t subscribed to match 743964!')
  end

  it 'displays scores for your cricket matches' do
    send_message('cricket -s 743963')
    send_message('cricket')
    # Not sure what to test for here :(
  end

  it 'displays the score for a specific match' do
    send_message('cricket 743963')
    send_message('cricket 0')
    # Not sure what to test for here :(
  end

  it 'adds or removes a favourite team and also updates your favourite teams if you mention cricket' do
    send_message('cricket -f Cromer Cricket Club')
    expect(replies.last).to eq('Subscribed you to favourite Cromer Cricket Club: OK')
    send_message('cricket is grouse')
    # it is tricky to test this last feature
    send_message('cricket -r Cromer Cricket Club')
    expect(replies.last).to eq('Unsubscribed you from favourite Cromer Cricket Club: OK')
    send_message('cricket -r Dee Why Cricket Club')
    expect(replies.last).to eq('Dee Why Cricket Club wasn\'t in your favourite list!')
    send_message('cricket -f Derbyshire')
    send_message('cricket')
  end

  it 'lists your favourite teams and subscribed matches' do
    send_message('cricket -i')
    expect(replies.detect{|x| ( x =~/Subscriptions:/ ) == 0}.nil?).to eq(false)
    expect(replies.detect{|x| ( x =~/Favourites:/ ) == 0}.nil?).to eq(false)
  end

end
