class HomeController < ApplicationController


  def index
    detail=domino_message_data
    @chart1_data={chart_data: detail.to_json}
    detail=domino_message_detail_by_message_type
    @chart2_data={chart_data: detail["IN"].to_json}
    @chart3_data={chart_data: detail["OUT"].to_json}
    detail=domino_message_detail_by_domain
    @chart4_data={chart_data: detail["OUT"].to_json}
    @chart5_data={chart_data: detail["IN"].to_json}
    detail=domino_message_history
    @chart6_data={chart_data: detail.to_json}





    respond_to do |format|
      format.html

    end
  end





  def live_data
    now=Time.now.advance(minutes: -5, :seconds=>Time.now.utc_offset).at_beginning_of_minute

    if params[:type]=="2"
      @data=[]
      d1=now.advance(minutes: -(now.min % 5))# arrotonda all'ultimo blocco da 5 minuti
      d0=d1.advance(minutes:-5) #5 minuti prima
      t0=(d1.to_i)*1000 #adesso in millisecondi
      @data[0]=[t0, Message.where(data:  Date.today, message_type: MESSAGE_TYPE_IN_INTERNET).where(["time between :d0 and :d1", d0: d0, d1: d1]).count("*")] #"Ricevuti"
      @data[1]=[t0, Message.where(data:  Date.today, message_type: MESSAGE_TYPE_OUT_INTERNET).where(["time between :d0 and :d1", d0: d0, d1: d1]).count("*") ]  #"Inviati"
      @data[2]=[t0, Message.where(data:  Date.today, message_type: (MESSAGE_TYPE_IN_CAMERA+MESSAGE_TYPE_OUT_CAMERA)).where(["time between :d0 and :d1", d0: d0, d1: d1]).count("*")] #"Interni camera"
      @data[3]=[t0, Message.where(data:  Date.today, message_type: (MESSAGE_TYPE_IN_SENATO+MESSAGE_TYPE_OUT_SENATO)).where(["time between :d0 and :d1", d0: d0, d1: d1]).count("*")] #"Interni senato"
      puts @data.inspect
      render json: @data
      return
    #elsif params[:type]=="3"
    #  @data=[]
    #  d1=now.advance(minutes: -(now.min % 5))  # arrotonda all'ultimo blocco da 5 minuti
    #  #d1=Time.now.advance(minutes: -(Time.now.min % 5)).at_beginning_of_minute  # arrotonda all'ultimo blocco da 5 minuti
    #  groups={}
    #  Group.where(group_type: params[:gt]).each{|g| groups[g.group_name]||=[] if !g.group_name.blank? ; groups[g.group_name]<<g.element if !g.group_name.blank?}
    #  @data << Message.where(data:  Date.today, to_type: groups[params[:t1]], message_type: MESSAGE_TYPE_IN_INTERNET).where(["time <= :d1", d1: d1]).count("*")
    #  @data << Message.where(data:  Date.today, from_type: groups[params[:f1]]).where(["time <= :d1", d1: d1]).count("*")
    #  @data<<=Message.where(data:  Date.today, to_type: groups[params[:t2]], message_type: MESSAGE_TYPE_IN_INTERNET).where(["time <= :d1", d1: d1]).count("*")
    #  @data<<=Message.where(data:  Date.today, from_type: groups[params[:f2]]).where(["time <= :d1", d1: d1]).count("*")
    #
    #
    #  render json: @data
    #  return
    elsif params[:type]=="4"
      @data=[]
      d1=now.advance(minutes: -(now.min % 5))  # arrotonda all'ultimo blocco da 5 minuti
      gt=params[:gt]

      params[:data].each do |k,data|

        if true
          count=Message.where(data:  Date.today)
          data[:filters].each do |kk,f|
            if f[:name]=="to_type"
              xx= Group.where(group_type: gt, group_name: f[:value]).map(&:element)
              count=count.where(to_type: xx)
            elsif f[:name]=="from_type"
              xx= Group.where(group_type: gt, group_name: f[:value]).map(&:element)
              count=count.where(from_type: xx)
            elsif f[:name]=="message_type"
              count=count.where(message_type: f[:value])
            else
              puts "#### NON GESTITO"
            end
          end
          @data << [data[:name], count.count]
        end
      end
      render json: @data
      return
    else
        d0=(now.to_i)*1000
        @data=[]
        @data[0]=[d0, Message.where(data:  Date.today, message_type: MESSAGE_TYPE_IN_INTERNET).count("*")] #"Ricevuti"
        @data[1]=[d0, Message.where(data:  Date.today, message_type: MESSAGE_TYPE_OUT_INTERNET).count("*") ]  #"Inviati"
        @data[2]=[d0, Message.where(data:  Date.today, message_type: (MESSAGE_TYPE_IN_CAMERA+MESSAGE_TYPE_OUT_CAMERA)).count("*")] #"Interni camera"
        @data[3]=[d0, Message.where(data:  Date.today, message_type: (MESSAGE_TYPE_IN_SENATO+MESSAGE_TYPE_OUT_SENATO)).count("*")] #"Interni senato"
        render json: @data
      return
      end



  end

  def domino_message_data

    now=Time.now.advance(:seconds=>Time.now.utc_offset).at_beginning_of_minute
    start_time=now.advance(minutes: -360)
    result={}
    tot={"IN"=>0, "OUT"=>0}

    #sql=["Select distinct  message_type from domino_messages where date > ?", start_time]
    #message_types=DominoMessage.find_by_sql(sql).map{|x| x.message_type}


    sql=["Select message_type , count(*) as tot from domino_messages where date >= ? and date < ? group by message_type", start_time.at_beginning_of_day, start_time]
    DominoMessage.find_by_sql(sql).each do |r|
      tot[r.message_type]=r.tot
    end

    sql=["Select extract(hour from date) as h , extract(minute from date) as m,  message_type,
        count(*) as tot from domino_messages where date > ?
        group by extract(hour from date) , extract(minute from date), message_type
        order by extract(hour from date) , extract(minute from date)", start_time]


    DominoMessage.find_by_sql(sql).each do |r|

      key_data=Date.today.to_time.advance(hours: (r.h+2), minutes: r.m).to_i*1000

      tot.keys.each do |t|
        tot[t] += r.tot if t==r.message_type
        if r.m%15==0
          result[key_data] ||= {}
          result[key_data][t]=tot[t]
        end
      end

      #puts [r.h, r.m, r.tot, r.message_type, tot[r.message_type]].inspect   if r.message_type=="OUT - forwarded"
      #puts "#{key_data} #{result[key_data].inspect}"
      #message_types.push r.message_type unless message_types.include?(r.message_type)
    end

    array=tot.keys.map{|t|
      {label: t.to_s,
       data: result.map{|k,v| [k, v[t].to_i]}
      }
    }


    return array

    #respond_to do |format|
    #    format.html { render text: @domino_message_data}
    #    format.json { render json: @domino_message_data}
    #end
  end
  def domino_message_history

      #IERI
      result={}
      array=[]
      tot={"IN"=>0, "OUT"=>0}
      -7.upto(0).each do |i|
      start_time=Date.today.advance(days: i)
      tot={"IN"=>0, "OUT"=>0}
      #sql=["Select message_type , count(*) as tot from domino_messages where date >= ? and date < ? group by message_type", start_time.at_beginning_of_day, start_time]
      #DominoMessage.find_by_sql(sql).each do |r|
      #  tot[r.message_type]=0
      #end

      sql=["Select extract(hour from date) as h ,  message_type ,
        count(*) as tot from domino_messages where date >= ? and date <= ?
        group by extract(hour from date) , message_type
        order by extract(hour from date) ", start_time.at_beginning_of_day, start_time.at_end_of_day]

      DominoMessage.find_by_sql(sql).each do |r|
        key_data=start_time.at_beginning_of_day.advance(hours: (r.h+2)).to_i*1000
        tot.keys.each do |t|
          tot[t] += r.tot if t==r.message_type
            result[key_data] ||= {}
            result[key_data][t]=tot[t]
        end
      end

      end
      array += tot.keys.map{|t|
        {label: "#{t.to_s}",
         data: result.map{|k,v| [k, v[t].to_i]}
        }
      }
    return array
  end
  def domino_message_detail_by_message_type
    start_time=Date.today
    result={}
    tot={}
    domino_message_detail={}
    ["IN","OUT"].each do |message_type|
    sql=["Select  message_subtype , count(*) as tot from domino_messages where message_type=? and date >= ?
        group by message_subtype",message_type, start_time]
    domino_message_detail[message_type]=DominoMessage.find_by_sql(sql).map{|r| {label:r.message_subtype, data:r.tot}}
    end
    return domino_message_detail
  end

  def domino_message_detail_by_domain
    start_time=Date.today
    result={}
    tot={}
    domino_message_detail={}
    sql=["Select  domain_from , count(*) as tot from domino_messages where message_type='IN' and date >= ?
       group by domain_from order by count(*) desc", start_time]
    domino_message_detail["IN"]=[]
    counter=0
    DominoMessage.find_by_sql(sql).each do |r|
      counter +=1
      if counter < 6
        domino_message_detail["IN"] << {label:"#{r.domain_from}", data:r.tot}
      else
        x=domino_message_detail["IN"].last
        x[:label]="Other Domains"
        x[:data] ||=0
        x[:data] += r.tot
      end
    end

    sql=["Select  domain_to , count(*) as tot from domino_messages where message_type='OUT' and date >= ?
        group by domain_to order by count(*) desc", start_time]
    counter=0
    domino_message_detail["OUT"]=[]
    DominoMessage.find_by_sql(sql).each do |r|
      counter +=1
      if counter < 6
        domino_message_detail["OUT"] << {label:"#{r.domain_to}",  data:r.tot}
      else
        x=domino_message_detail["OUT"].last
        x[:label]="Other Domains"
        x[:data] ||=0
        x[:data] += r.tot
      end
    end


    return domino_message_detail
  end

  def test_domino_message_data
    @domino_message_detail=domino_message_history
    respond_to do |format|
        format.html { render text: @domino_message_detail}
        format.json { render json: @domino_message_detail}
    end
  end



  def live_mail_relay

    #subj=EximLog.where(date: Date.today).group("subject")
    result={inviate: {}, ricevute:{}}

    base_search=EximLog.where("1=1")
    params[:search_date_from]||=Date.today
    params[:search_date_to]||=Date.today

    base_search = base_search.where(["date >= ?", params[:search_date_from]])
    base_search = base_search.where(["date <= ?", params[:search_date_to]])

    base_search = base_search.where(["mail_from like ?", params[:search_mail_from]]) unless params[:search_mail_from].blank?
    base_search = base_search.where(["mail_to like ?", params[:search_mail_to]]) unless params[:search_mail_to].blank?
    base_search = base_search.where(["subject like ?", params[:search_subject]]) unless params[:search_subject].blank?

    params[:search_limit] ||=1000

    a=base_search.inviate.group("subject").having(["sum(mail_to_count) > ?",params[:search_limit]])
    #b=result[:inviate]
    b=Hash.new()

    a.sum(:mail_to_camera_count).each {|k,v| b[k]||={};b[k][:mail_to_camera_count]=v}
    a.sum(:mail_to_count).each { |k,v| b[k]||={};b[k][:mail_to_count]=v}
    a.count(:id).each {|k,v| b[k]||={};b[k][:mail_count]=v }

    result[:inviate].merge!(b)

    a=base_search.ricevute.group("subject").having(["count(id) > ?",params[:search_limit]])
    #a=EximLog.ricevute.where(date: Date.today).group("subject") .having("count(id) > 100")
    #b=result[:ricevute]
    b=Hash.new()
    a.sum(:mail_to_camera_count).each {|k,v| b[k]||={};b[k][:mail_to_camera_count]=v}
    a.sum(:mail_to_count).each { |k,v| b[k]||={};b[k][:mail_to_count]=v}
    a.count(:id).each {|k,v| b[k]||={};b[k][:mail_count]=v }
    result[:ricevute].merge!(b)


    @result=result
  end
  def blank

  end

  def notifications

  end
  def flot

  end
  def morris

  end
  def locks
    @locks=DominoLock.where(["updated_at > ?", Date.today]).group_by{|x| x.database_name}
    #render text:  @locks.inspect
  end

  def tables

  end
  def panels_wells

  end
  def buttons

  end
  def typography

  end
  def grid

  end
  def forms

  end
end
