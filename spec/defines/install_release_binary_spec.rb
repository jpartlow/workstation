require 'spec_helper'

describe 'workstation::install_release_binary' do
  let(:title) { 'org/proj/test' }
  let(:params) { {} }

  it { is_expected.to compile.with_all_deps }

  context 'tarball' do
    let(:params) do
      {
        package: 'test.tar.gz',
        creates: 'test',
      }
    end

    it 'downloads' do
      is_expected.to(
        contain_exec('install-test')
        .with_command(/curl .*org.proj.releases.download.*test\.tar\.gz"/)
      )
    end

    it 'untars' do
      is_expected.to(
        contain_exec('install-test')
          .with_command(/tar -xf test\.tar\.gz/)
      )
    end

    it 'moves to install dir' do
      is_expected.to(
        contain_exec('install-test')
          .with_command(/mv test \/usr\/local\/bin\/test/)
      )
    end

    it 'can find a specific archive file' do
      params[:archive_file] = 'some/binary'
      is_expected.to(
        contain_exec('install-test')
          .with_command(/mv some\/binary \/usr\/local\/bin\/test/)
      )
    end

    it 'checks for installed binary' do
      is_expected.to(
        contain_exec('install-test')
          .with_creates('/usr/local/bin/test')
      )
    end
  end

  context 'untarred binary' do
    it 'downloads' do
      is_expected.to(
        contain_exec('install-test')
        .with_command(/curl .*org.proj.releases.download.*test"/)
      )
    end

    it 'moves to install dir' do
      is_expected.to(
        contain_exec('install-test')
          .with_command(/mv test \/usr\/local\/bin\/test/)
      )
    end

    it 'chmods' do
      is_expected.to(
        contain_exec('install-test')
          .with_command(/chmod \+x test/)
      )
    end

    it 'checks for installed binary' do
      is_expected.to(
        contain_exec('install-test')
          .with_creates('/usr/local/bin/test')
      )
    end
  end

  it 'gets exact version' do
    params[:version] = '0.1.0'
    is_expected.to(
      contain_exec('install-test')
        .with_command(/VERSION=0\.1\.0/)
    )
  end

  it 'can replace the download url' do
    params[:download_url] = 'https://some.where.else'
    is_expected.to(
      contain_exec('install-test')
        .with_command(/curl .* "https:\/\/some\.where\.else\/test"/)
    )
  end
end
