RSpec.describe AssignedToTrello do
  let(:trello_url) { 'https://api.trello.com/1' }
  let(:trello_auth) { 'key=TRELLO_PUBLIC_KEY&token=TRELLO_MEMBER_TOKEN' }

  before do
    stub_fixture 'https://api.github.com/issues', 'issues'
    stub_fixture "#{trello_url}/boards/TRELLO_BOARD_ID?#{trello_auth}", 'board'
    stub_fixture "#{trello_url}/boards/board/cards?filter=open&#{trello_auth}", 'cards'
    stub_fixture "#{trello_url}/cards/card-with-attachment/attachments?#{trello_auth}", 'attachment'
    stub_fixture "#{trello_url}/cards/card-without-attachment/attachments?#{trello_auth}", 'empty_array'
    stub_fixture "#{trello_url}/boards/board/lists?filter=open&#{trello_auth}", 'lists'
  end

  before do
    %w[
      GITHUB_TOKEN TRELLO_PUBLIC_KEY TRELLO_MEMBER_TOKEN
      TRELLO_BOARD_ID TRELLO_LIST_NAME
    ].each do |key|
      ENV[key] = key
    end
  end

  before do
    Trello.configure do |config|
      config.developer_public_key = ENV['TRELLO_PUBLIC_KEY']
      config.member_token         = ENV['TRELLO_MEMBER_TOKEN']
    end
  end

  it 'inits octokit' do
    expect(subject.octokit).to be_a(Octokit::Client)
  end

  it 'retrieves the board' do
    expect(subject.board).to be_a(Trello::Board)
    expect(subject.board.name).to eql('My board')
  end

  it 'retrieves the list' do
    expect(subject.list).to be_a(Trello::List)
    expect(subject.list.name).to eql('TRELLO_LIST_NAME')
  end

  it 'returns issues' do
    expect(subject.issues.count).to eql(2)
    expect(subject.issues.first.title).to eql('Issue with card')
  end

  it 'returns cards' do
    expect(subject.cards.count).to eql(2)
    expect(subject.cards.first.name).to eql('Card with attachment')
  end

  it 'finds a card by issue' do
    issue = subject.issues.first
    card = subject.find_card_by_issue(issue)
    expect(card.name).to eql('Card with attachment')
    expect(card.attachments.first.url).to eql(issue.html_url)
  end

  context 'creating a card' do
    before do
      @card_stub = stub_request(:post, "#{trello_url}/cards?#{trello_auth}")
                   .with(body: { 'desc' => nil, 'due' => nil, 'dueComplete' => 'false', 'idCardSource' => nil, 'idLabels' => nil, 'idList' => 'list', 'idMembers' => nil, 'keepFromSource' => 'all', 'name' => 'Issue without card', 'pos' => nil })
                   .to_return(
                     status: 200,
                     body: fixture('card'),
                     headers: { 'Content-Type' => 'application/json' }
                   )

      @attachment_stub = stub_request(:post, "#{trello_url}/cards/issue-without-card/attachments?#{trello_auth}")
                         .with(body: { 'name' => 'https://github.com/foo/bar/issues/2', 'url' => 'https://github.com/foo/bar/issues/2' })
                         .to_return(status: 200, body: '', headers: {})
    end

    it 'creates a card from an issue' do
      issue = subject.issues.last
      card = subject.create_card_from_issue(issue)
      expect(card.name).to eql('Issue without card')
      expect(@card_stub).to have_been_requested
      expect(@attachment_stub).to have_been_requested
    end

    it 'Creates new issues' do
      subject.run
      expect(@card_stub).to have_been_requested
      expect(@attachment_stub).to have_been_requested
    end
  end
end
