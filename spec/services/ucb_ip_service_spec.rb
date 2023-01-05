require 'rails_helper'

describe UcbIpService do
  describe :ucb_request? do
    attr_reader :request
    attr_reader :headers

    before do
      html_source = File.read('spec/data/campus-networks.txt')
      campus_networks_uri = Rails.application.config.campus_networks_uri
      stub_request(:get, campus_networks_uri).to_return(status: 200, body: html_source)

      @request = instance_double(ActionDispatch::Request)
      @headers = instance_double(ActionDispatch::Http::Headers)
      allow(request).to receive(:headers).and_return(headers)
    end

    describe 'x-forwarded-for' do
      describe 'staging' do
        before do
          remote_ip = instance_double(ActionDispatch::RemoteIp::GetIp)
          allow(remote_ip).to receive(:to_s).and_return('128.32.10.191')
          allow(headers).to receive(:[]).with('action_dispatch.remote_ip').and_return(remote_ip)
        end

        it 'returns true for a campus IP' do
          allow(headers).to receive(:[]).with('HTTP_X_FORWARDED_FOR').and_return('128.32.10.191, 136.152.24.200')
          expect(UcbIpService.ucb_request?(request)).to eq(true)
        end

        it 'returns true for an AirBears IP' do
          allow(headers).to receive(:[]).with('HTTP_X_FORWARDED_FOR').and_return('128.32.10.191, 10.142.128.127')
          expect(UcbIpService.ucb_request?(request)).to eq(true)
        end

        it 'returns true for a split tunnel IP' do
          allow(headers).to receive(:[]).with('HTTP_X_FORWARDED_FOR').and_return('128.32.10.191, 10.136.128.127')
          expect(UcbIpService.ucb_request?(request)).to eq(true)
        end

        it 'returns false for a non-campus IP' do
          allow(headers).to receive(:[]).with('HTTP_X_FORWARDED_FOR').and_return('128.32.10.191, 8.8.8.8')
          expect(UcbIpService.ucb_request?(request)).to eq(false)
        end

        it 'returns false if all we get is the load balancer IP' do
          allow(headers).to receive(:[]).with('HTTP_X_FORWARDED_FOR').and_return('128.32.10.191')
          expect(UcbIpService.ucb_request?(request)).to eq(false)
        end
      end

      describe 'production' do
        attr_reader :remote_ip

        before do
          @remote_ip = instance_double(ActionDispatch::RemoteIp::GetIp)
          allow(headers).to receive(:[]).with('action_dispatch.remote_ip').and_return(remote_ip)
        end

        it 'returns true for an IP in the campus networks table' do
          ip_addr = '136.152.24.200'
          allow(remote_ip).to receive(:to_s).and_return(ip_addr)
          allow(headers).to receive(:[]).with('HTTP_X_FORWARDED_FOR').and_return("#{ip_addr}, 10.255.0.10")
          expect(UcbIpService.ucb_request?(request)).to eq(true)
        end

        it 'returns true for a campus IP in the AirBears range' do
          ip_addr = '10.142.128.127'
          allow(remote_ip).to receive(:to_s).and_return(ip_addr)
          allow(headers).to receive(:[]).with('HTTP_X_FORWARDED_FOR').and_return("#{ip_addr}, 10.255.0.10")
          expect(UcbIpService.ucb_request?(request)).to eq(true)
        end

        it 'returns true for a split tunnel IP' do
          ip_addr = '10.136.128.127'
          allow(remote_ip).to receive(:to_s).and_return(ip_addr)
          allow(headers).to receive(:[]).with('HTTP_X_FORWARDED_FOR').and_return("#{ip_addr}, 10.255.0.10")
          expect(UcbIpService.ucb_request?(request)).to eq(true)
        end

        it 'returns false for a non-campus IP' do
          ip_addr = '8.8.8.8'
          allow(remote_ip).to receive(:to_s).and_return(ip_addr)
          allow(headers).to receive(:[]).with('HTTP_X_FORWARDED_FOR').and_return("#{ip_addr}, 10.255.0.10")
          expect(UcbIpService.ucb_request?(request)).to eq(false)
        end

        it 'returns true for EZProxy' do
          ip_addr = '128.32.10.230'
          allow(remote_ip).to receive(:to_s).and_return(ip_addr)
          allow(headers).to receive(:[]).with('HTTP_X_FORWARDED_FOR').and_return("#{ip_addr}, 10.255.0.10")
          expect(UcbIpService.ucb_request?(request)).to eq(true)
        end
      end
    end

    describe 'remote IP without x-forwarded-for' do
      before do
        allow(headers).to receive(:[]).with('HTTP_X_FORWARDED_FOR').and_return(nil)
      end

      it 'returns true for localhost' do
        remote_ip = instance_double(ActionDispatch::RemoteIp::GetIp)
        allow(remote_ip).to receive(:to_s).and_return('127.0.0.1')
        allow(headers).to receive(:[]).with('action_dispatch.remote_ip').and_return(remote_ip)

        expect(UcbIpService.ucb_request?(request)).to eq(true)
      end
    end
  end

  describe :campus_ip? do
    attr_reader :service

    before do
      @service = UcbIpService.new
    end

    describe 'with IP list available' do
      before do
        html_source = File.read('spec/data/campus-networks.txt')
        campus_networks_uri = Rails.application.config.campus_networks_uri
        stub_request(:get, campus_networks_uri).to_return(status: 200, body: html_source)
      end

      it 'returns true for a campus IP' do
        expect(service.campus_ip?('128.32.128.127')).to eq(true)
      end

      it 'returns true for an AirBears IP' do
        expect(service.campus_ip?('10.142.128.127')).to eq(true)
      end

      it 'returns true for a split tunnel IP' do
        expect(service.campus_ip?('10.136.128.127')).to eq(true)
      end

      it 'accepts IPAddr objects' do
        ipaddr = IPAddr.new('128.32.128.127')
        expect(service.campus_ip?(ipaddr)).to eq(true)
      end

      it 'returns false for a non-campus IP' do
        expect(service.campus_ip?('8.8.8.8')).to eq(false)
      end

      it 'returns false for nil' do
        expect(service.campus_ip?(nil)).to eq(false)
      end
    end

    describe 'with IP list unavailable' do
      it 'returns false if IP list 404s' do
        campus_networks_uri = Rails.application.config.campus_networks_uri
        stub_request(:get, campus_networks_uri).to_return(status: 404)
        expect(service.campus_ip?('128.32.128.127')).to eq(false)
      end

      it 'returns false if IP list returns something weird' do
        campus_networks_uri = Rails.application.config.campus_networks_uri
        stub_request(:get, campus_networks_uri).to_return(status: 207)
        expect(service.campus_ip?('128.32.128.127')).to eq(false)
      end

      it 'retries on next request' do
        campus_networks_uri = Rails.application.config.campus_networks_uri
        stub_request(:get, campus_networks_uri).to_return(status: 404)
        expect(service.campus_ip?('128.32.128.127')).to eq(false)

        html_source = File.read('spec/data/campus-networks.txt')
        campus_networks_uri = Rails.application.config.campus_networks_uri
        stub_request(:get, campus_networks_uri).to_return(status: 200, body: html_source)
        expect(service.campus_ip?('128.32.128.127')).to eq(true)
      end
    end
  end
end
