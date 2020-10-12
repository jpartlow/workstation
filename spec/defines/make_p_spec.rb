require 'spec_helper'

describe 'workstation::make_p' do
  let(:title) { '/foo/bar/baz' }
  let(:params) do
    {
        user: 'test',
    }
  end

  context 'absolute' do
    it 'generates directories' do
      is_expected.to(
        contain_file('/foo')
          .with_ensure('directory')
          .with_owner('test')
      )
      is_expected.to contain_file('/foo/bar')
      is_expected.to contain_file('/foo/bar/baz')
    end

    it 'just generates the three' do
      is_expected.to have_file_resource_count(3)
    end
  end

  context 'relative with root' do
    let(:title) { 'foo/bar/baz' }
    let(:params) do
      {
        root_prefix: '/home/test',
        user:        'test',
      }
    end

    it do
      is_expected.to contain_file('/home/test/foo')
      is_expected.to contain_file('/home/test/foo/bar')
      is_expected.to(
        contain_file('/home/test/foo/bar/baz')
          .with_ensure('directory')
          .with_owner('test')
      )
    end
  end

  context 'skips prexisting dirs' do
    let(:pre_condition) do
      <<~PRE
        file { '/foo': ensure => directory }
      PRE
    end

    it 'just generates the three' do
      is_expected.to contain_file('/foo/bar')
      is_expected.to contain_file('/foo/bar/baz')
      is_expected.to have_file_resource_count(3)
    end
  end

  it 'errors if given absolute and root' do
    params[:root_prefix] = '/home/test'

    is_expected.to compile.and_raise_error(/The path.*should not be absolute/)
  end
end
