# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SyncLog do
  let(:user) { create(:user) }
  let(:task_name) { 'test_task' }

  describe 'validations' do
    it { should validate_presence_of(:task_name) }
    it { should validate_presence_of(:started_at) }
    it { should validate_presence_of(:user) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe '.start!' do
    context 'when no task is in progress' do
      it 'creates a new SyncLog' do
        expect do
          user.sync_logs.start!(task_name:)
        end.to change(SyncLog, :count).by(1)
      end

      it 'sets the correct attributes' do
        sync_log = user.sync_logs.start!(task_name:)
        expect(sync_log.task_name).to eq(task_name)
        expect(sync_log.started_at).to be_present
        expect(sync_log.ended_at).to be_nil
      end
    end

    context 'when a task is already in progress' do
      before { user.sync_logs.start!(task_name:) }

      it 'raises an error' do
        expect do
          user.sync_logs.start!(task_name:)
        end.to raise_error(StandardError, 'cannot start a task when one is already in progress')
      end
    end
  end

  describe '#mark_as_completed!' do
    let(:sync_log) { user.sync_logs.start!(task_name:) }

    context 'when the task is in progress' do
      it 'sets the ended_at timestamp' do
        expect do
          sync_log.mark_as_completed!
        end.to change { sync_log.reload.ended_at }.from(nil)
      end
    end

    context 'when the task is already completed' do
      before { sync_log.mark_as_completed! }

      it 'raises an error' do
        expect do
          sync_log.mark_as_completed!
        end.to raise_error(StandardError, 'cannot mark a task as completed when it is already completed')
      end
    end
  end

  describe '.latest' do
    it 'returns the most recent SyncLog for the given task' do
      old_log = user.sync_logs.start!(task_name:)
      old_log.mark_as_completed!

      new_log = user.sync_logs.start!(task_name:)
      expect(user.sync_logs.latest(task_name)).to eq(new_log)
    end

    context 'when a sync log is already in progress' do
      it 'raises an error' do
        user.sync_logs.start!(task_name:)

        expect do
          user.sync_logs.start!(task_name:)
        end.to raise_error(StandardError, 'cannot start a task when one is already in progress')
      end
    end
  end

  describe '#in_progress?' do
    it 'returns true when ended_at is nil' do
      sync_log = user.sync_logs.start!(task_name:)
      expect(sync_log).to be_in_progress
    end

    it 'returns false when ended_at is present' do
      sync_log = user.sync_logs.start!(task_name:)
      sync_log.mark_as_completed!
      expect(sync_log).not_to be_in_progress
    end
  end

  describe '#completed?' do
    it 'returns true when ended_at is present' do
      sync_log = user.sync_logs.start!(task_name:)
      sync_log.mark_as_completed!
      expect(sync_log).to be_completed
    end

    it 'returns false when ended_at is nil' do
      sync_log = user.sync_logs.start!(task_name:)
      expect(sync_log).not_to be_completed
    end
  end
end
