class PoolsController < ApplicationController
  def index
    @pools = get_rig_pools
  end

  def switch
    if miner = miners.find { |miner| miner.id == params[:rig_id] }
      miner.rpc.cmd_switchpool(params[:pool])
      redirect_to pools_url, flash: { notice: "Successfully switched pool on rig #{miner.to_s}." }
    else
      redirect_to pools_url, flash: { warning: "Cannot find rig." }
    end
  end

  def create
    miners.each do |miner|
      next if miner.rpc.cmd_pools["POOLS"].find { |p| p["URL"] == params[:url] && p["User"] == params[:user] }
      miner.rpc.cmd_addpool(params[:url], params[:user], params[:pass])
    end

    redirect_to pools_url, flash: { notice: "Pool added." }
  end

private
  def get_rig_pools
    data = Hash.new
    miners.each do |miner|
      begin
        rpc = miner.rpc
        data[miner] = rpc.cmd_pools["POOLS"].sort_by do |pool|
          pool["Priority"]
        end
      rescue StandardError
        nil
      end
    end
    data
  end
end
