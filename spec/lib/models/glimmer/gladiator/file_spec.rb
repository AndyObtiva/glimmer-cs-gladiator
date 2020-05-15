require 'spec_helper'

describe Glimmer::Gladiator::File do
  let(:empty_file   )  { File.join(SPEC_ROOT, 'fixtures/empty_file'   ) }
  let(:one_line_file)  { File.join(SPEC_ROOT, 'fixtures/one_line_file') }
  let(:two_line_file)  { File.join(SPEC_ROOT, 'fixtures/two_line_file') }
  let(:ten_line_file)  { File.join(SPEC_ROOT, 'fixtures/ten_line_file') }
  
  describe '#move_up!' do
    context 'in an empty file' do
      it 'does not move line down' do
        subject = described_class.new(empty_file)
  
        subject.line_number = 1
  
        expect(subject.caret_position).to eq(0)
  
        subject.move_up!
  
        expect(subject.caret_position).to eq(0)
        expect(subject.line_number).to eq(1)

        subject.format_dirty_content_for_writing!
  
        expect(subject.dirty_content).to eq("\n")
      end
    end

    context 'in a one line file' do
      it 'does not move line up' do
        subject = described_class.new(one_line_file)
  
        subject.line_number = 1
  
        expect(subject.caret_position).to eq(0)
  
        subject.move_up!
  
        expect(subject.caret_position).to eq(0)
        expect(subject.line_number).to eq(1)

        subject.format_dirty_content_for_writing!
  
        expect(subject.dirty_content).to eq(<<~MULTI
          one Hello, World! and Hello, World! and Hello, World!
        MULTI
        )
      end
    end

    context 'in a two line file' do
      it 'moves one line up' do
        subject = described_class.new(two_line_file)
  
        subject.line_number = 2
  
        expect(subject.caret_position).to eq(54)
  
        subject.move_up!
  
        expect(subject.caret_position).to eq(0)
        expect(subject.line_number).to eq(1)
  
        subject.format_dirty_content_for_writing!
  
        expect(subject.dirty_content).to eq(<<~MULTI
          two Howdy, Universe! and Howdy, Universe! and Howdy, Universe!
          one Hello, World! and Hello, World! and Hello, World!
        MULTI
        )
      end  
    end

    context 'in a ten line file' do
      it 'moves two lines up' do
        subject = described_class.new(ten_line_file)
  
        subject.line_number = 3
        subject.selection_count = 175
  
        expect(subject.caret_position).to eq(117)
  
        subject.move_up!
  
        expect(subject.caret_position).to eq(54)
        expect(subject.selection_count).to eq(175)
        expect(subject.line_number).to eq(2)

        subject.format_dirty_content_for_writing!
  
        expect(subject.dirty_content).to eq(<<~MULTI
          one Hello, World! and Hello, World! and Hello, World!
          three Hello, World! and Hello, World! and Hello, World!
          four Howdy, Universe! and Howdy, Universe! and Howdy, Universe!
          five Hello, World! and Hello, World! and Hello, World!
          two Howdy, Universe! and Howdy, Universe! and Howdy, Universe!
          six Howdy, Universe! and Howdy, Universe! and Howdy, Universe!
          seven Hello, World! and Hello, World! and Hello, World!
          eight Howdy, Universe! and Howdy, Universe! and Howdy, Universe!
          nine Hello, World! and Hello, World! and Hello, World!
          ten Howdy, Universe! and Howdy, Universe! and Howdy, Universe!
        MULTI
        )
      end
    end
  end
  
  describe '#move_down!' do
    context 'in an empty file' do
      it 'does not move line down' do
        subject = described_class.new(empty_file)
  
        subject.line_number = 1
  
        expect(subject.caret_position).to eq(0)
  
        subject.move_down!
  
        expect(subject.caret_position).to eq(0)
        expect(subject.line_number).to eq(1)

        subject.format_dirty_content_for_writing!
  
        expect(subject.dirty_content).to eq("\n")
      end
    end

    context 'in a one line file' do
      it 'does not move line down' do
        subject = described_class.new(one_line_file)
  
        subject.line_number = 1
  
        expect(subject.caret_position).to eq(0)
  
        subject.move_down!
  
        expect(subject.caret_position).to eq(0)
        expect(subject.line_number).to eq(1)

        subject.format_dirty_content_for_writing!
  
        expect(subject.dirty_content).to eq(<<~MULTI
          one Hello, World! and Hello, World! and Hello, World!
        MULTI
        )
      end
    end

    context 'in a two line file' do
      it 'moves one line down' do
        subject = described_class.new(two_line_file)
  
        subject.line_number = 1
  
        expect(subject.caret_position).to eq(0)
  
        subject.move_down!
  
        expect(subject.caret_position).to eq(63)
        expect(subject.line_number).to eq(2)
  
        subject.format_dirty_content_for_writing!
  
        expect(subject.dirty_content).to eq(<<~MULTI
          two Howdy, Universe! and Howdy, Universe! and Howdy, Universe!
          one Hello, World! and Hello, World! and Hello, World!
        MULTI
        )
      end
    end

    context 'in a ten line file' do
      it 'moves two lines down' do
        subject = described_class.new(ten_line_file)
  
        subject.line_number = 2
        subject.selection_count = 119
  
        expect(subject.caret_position).to eq(54)
  
        subject.move_down!
  
        expect(subject.caret_position).to eq(118)
        expect(subject.selection_count).to eq(119)
        expect(subject.line_number).to eq(3)

        subject.format_dirty_content_for_writing!
  
        expect(subject.dirty_content).to eq(<<~MULTI
          one Hello, World! and Hello, World! and Hello, World!
          four Howdy, Universe! and Howdy, Universe! and Howdy, Universe!
          two Howdy, Universe! and Howdy, Universe! and Howdy, Universe!
          three Hello, World! and Hello, World! and Hello, World!
          five Hello, World! and Hello, World! and Hello, World!
          six Howdy, Universe! and Howdy, Universe! and Howdy, Universe!
          seven Hello, World! and Hello, World! and Hello, World!
          eight Howdy, Universe! and Howdy, Universe! and Howdy, Universe!
          nine Hello, World! and Hello, World! and Hello, World!
          ten Howdy, Universe! and Howdy, Universe! and Howdy, Universe!
        MULTI
        )
      end
    end
  end
end
