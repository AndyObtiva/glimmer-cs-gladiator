require 'spec_helper'

describe Glimmer::Gladiator::File do
  let(:empty_file)     {File.join(SPEC_ROOT, 'fixtures/empty_file')}
  let(:one_line_file)  {File.join(SPEC_ROOT, 'fixtures/one_line_file')}
  let(:two_line_file)  {File.join(SPEC_ROOT, 'fixtures/two_line_file')}
  let(:ten_line_file)  {File.join(SPEC_ROOT, 'fixtures/ten_line_file')}

  describe '#move_up!' do
    it 'moves one line up' do
      subject = described_class.new(two_line_file)

      subject.line_number = 2

      expect(subject.caret_position).to eq(54)

      subject.move_up!

      subject.format_dirty_content_for_writing!

      expect(subject.dirty_content).to eq(<<~MULTI
        two Howdy, Universe! and Howdy, Universe! and Howdy, Universe!
        one Hello, World! and Hello, World! and Hello, World!
      MULTI
      )
    end
  end
end
