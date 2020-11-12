require 'spec_helper'

describe 'workstation::packages' do
  it { is_expected.to compile.with_all_deps }
 
  it 'installs nothing' do
    is_expected.to have_package_resource_count(0)
  end

  context 'on redhat' do
    let(:facts) do
      {
        os: {
          family: 'RedHat',
        }
      }
    end

    it 'installs nothing' do
      is_expected.to have_package_resource_count(0)
    end

    context 'with packages' do
      let(:params) do
        {
          packages: [ 'apackage' ],
        }
      end

      it 'includes epel-release' do
        is_expected.to contain_package('epel-release')
        is_expected.to have_package_resource_count(2)
      end

      context 'and epel skipped' do
        it 'skips epel-release' do
          params[:install_epel] = false
          is_expected.to contain_package('apackage')
          is_expected.to have_package_resource_count(1)
        end
      end
    end
  end
end
