class HomeController < ApplicationController

  MESSAGE_TYPE_OUT_CAMERA = ["OUT - VERSO DOMINIO CAMERA","INTERNO via web", "INTERNO via smtp"]
  MESSAGE_TYPE_OUT_SENATO = ["OUT - VERSO DOMINIO SENATO"]
  MESSAGE_TYPE_OUT_INTERNET = ["OUT - VERSO INTERNET", "FORWARDED","FORWARDED by Rule"]

  MESSAGE_TYPE_IN_CAMERA = ["IN - DA DOMINIO CAMERA", "INTERNO via web", "INTERNO via smtp"]
  MESSAGE_TYPE_IN_SENATO = ["IN - DA DOMINIO SENATO"]
  MESSAGE_TYPE_IN_INTERNET = [ "IN - DA INTERNET"]

  MESSAGE_TYPE_OUT =    MESSAGE_TYPE_OUT_CAMERA +  MESSAGE_TYPE_OUT_SENATO + MESSAGE_TYPE_OUT_INTERNET
  #["OUT - VERSO DOMINIO CAMERA","OUT - VERSO INTERNET", "FORWARDED","FORWARDED by Rule","INTERNO via web", "INTERNO via smtp"]
  MESSAGE_TYPE_IN = MESSAGE_TYPE_IN_CAMERA +  MESSAGE_TYPE_IN_SENATO  + MESSAGE_TYPE_IN_INTERNET
  #["IN - DA DOMINIO CAMERA", "IN - DA INTERNET","INTERNO via web", "INTERNO via smtp"]



  def self.charts
     self.action_methods.map{|x| x if x.starts_with?("chart_")}.compact
  end

  def index

  end

  def chart
    return if params[:chart_name].blank?
    @date_from=Date.parse(params[:date][:from]) if params[:date]
    @date_to=Date.parse(params[:date][:to]) if params[:date]
    @group_type=params[:group_type]
    @date_from||=Date.today.advance(months: -1)
    @date_to||=Date.today
    @date_array=(@date_from..@date_to).to_a.map{|x| x.to_s}
    @date_hash={}
    (@date_from..@date_to).each{|x| @date_hash[x.to_s]=0}
    #@group_type=params[:group_type] || "17ma_leg"
    @groups={}
    @data={}
    self.send(params[:chart_name].to_sym)  if self.respond_to? params[:chart_name].to_sym


  end



  def chart_inviati
    #sql="select count(m.*) as tot from messaggiout m where m.data=? and m.from_type in (?)"
    #sql="select m.data, count(m.*) as tot from messaggiout m where m.data between ? and ? and m.from_type in (?) group by m.data"
    #sql="select m.data, count(m.*) as tot from messages m where m.data between ? and ? and m.from_type in (?) and m.message_type in (?) group by m.data"
    #sql="select m.data, count(m.*) as tot from messaggiout m where m.data between ? and ? and m.from_type in (?) and m.message_type in (?) group by m.data"
    Group.where(group_type: @group_type).each{|g| @groups[g.group_name]||=[] if !g.group_name.blank? ; @groups[g.group_name]<<g.element if !g.group_name.blank?}
    @bar = LazyHighCharts::HighChart.new('column') do |f|
      @groups.each do |g,v|
        @data["#{g} INTERNI"]={}
        data=@data["#{g} INTERNI"]
        #Message.find_by_sql([sql,@date_from, @date_to,v,MESSAGE_TYPE_OUT_CAMERA]).each{|x| data[x.data.to_s]=x.tot}
        Message.where(data:  (@date_from..@date_to), from_type: v, message_type: MESSAGE_TYPE_OUT_CAMERA).group("data").count("*").each{|k,v| data[k.to_s]=v}
        #).each{|x| data[x.data.to_s]=x.tot}
        data.reverse_merge!(@date_hash)
        f.series(:name=>"#{g} INTERNI",:data=>data.keys.sort.map{|x| data[x]}, stack: "INTERNI")
        @data["#{g} VERSO INTERNET"]={}
        data=@data["#{g} VERSO INTERNET"]
        #Message.find_by_sql([sql,@date_from, @date_to,v,MESSAGE_TYPE_OUT_INTERNET]).each{|x| data[x.data.to_s]=x.tot}
        Message.where(data:  (@date_from..@date_to), from_type: v, message_type: MESSAGE_TYPE_OUT_INTERNET).group("data").count("*").each{|k,v| data[k.to_s]=v}
        data.reverse_merge!(@date_hash)
        f.series(:name=>"#{g} VERSO INTERNET",:data=>data.keys.sort.map{|x| data[x]}, stack: "VERSO INTERNET")
      end
      #f.series(:name=>"CAMERA",:data=> Message.find_by_sql([sql_tot,MESSAGE_TYPE_OUT_CAMERA,@date_from, @date_to]).map{|x| x.tot})
      #f.series(:name=>"INTERNET",:data=> Message.find_by_sql([sql_tot,MESSAGE_TYPE_OUT_INTERNET,@date_from, @date_to]).map{|x| x.tot})

      f.title({ :text=>"Messaggi Inviati (sia verso dominio camera che verso internet)"})
      f.options[:xAxis] ={categories: @date_array, labels: {rotation: 270}}
      f.options[:chart][:defaultSeriesType] = "column"
      f.options[:showInLegend]= false
      f.options[:dataLabels]={:enabled=> false}
      f.options[:legend]={:floating=> false, layout: "horizontal"}
      f.plot_options({:column=>{:stacking=>"normal"}})
    end
  end

  def chart_ricevuti
    @data={}
    sql="select m.data, count(m.*) as tot from messaggiin m where m.data between ? and ? and m.to_type in (?) and m.message_type in (?) group by m.data"
    Group.where(group_type: @group_type).each{|g| @groups[g.group_name]||=[] if !g.group_name.blank? ; @groups[g.group_name]<<g.element if !g.group_name.blank?}
    @bar = LazyHighCharts::HighChart.new('column') do |f|
      @groups.each do |g,v|
        @data["#{g} INTERNI"]={}
        data=@data["#{g} INTERNI"]
        #Message.find_by_sql([sql,@date_from, @date_to,v,MESSAGE_TYPE_IN_CAMERA]).each{|x| data[x.data.to_s]=x.tot}
        Message.where(data:  (@date_from..@date_to), to_type: v, message_type: MESSAGE_TYPE_IN_CAMERA).group("data").count("*").each{|k,v| data[k.to_s]=v}
        data.reverse_merge!(@date_hash)
        f.series(:name=>"#{g} INTERNI",:data=>data.keys.sort.map{|x| data[x]}, stack: "INTERNI")
        @data["#{g} DA INTERNET"]={}
        data=@data["#{g} DA INTERNET"]
        #Message.find_by_sql([sql,@date_from, @date_to,v,MESSAGE_TYPE_IN_INTERNET]).each{|x| data[x.data.to_s]=x.tot}
        Message.where(data:  (@date_from..@date_to), to_type: v, message_type: MESSAGE_TYPE_IN_INTERNET).group("data").count("*").each{|k,v| data[k.to_s]=v}
        data.reverse_merge!(@date_hash)
        f.series(:name=>"#{g} DA INTERNET",:data=>data.keys.sort.map{|x| data[x]}, stack: "DA INTERNET")
      end
      #f.series(:name=>"CAMERA",:data=> Message.find_by_sql([sql_tot,MESSAGE_TYPE_OUT_CAMERA,@date_from, @date_to]).map{|x| x.tot})
      #f.series(:name=>"INTERNET",:data=> Message.find_by_sql([sql_tot,MESSAGE_TYPE_OUT_INTERNET,@date_from, @date_to]).map{|x| x.tot})

      f.title({ :text=>"Messaggi Ricevuti (sia dal dominio camera che da internet)"})
      f.options[:xAxis] ={categories: @date_array, labels: {rotation: 270}}
      f.options[:chart][:defaultSeriesType] = "column"
      f.options[:legend]={:floating=> true}
      f.options[:showInLegend]= false
      f.options[:legend]={:floating=> false, layout: "horizontal"}
      f.options[:dataLabels]={:enabled=> false}
      f.plot_options({:column=>{:stacking=>"normal"}})
    end
  end

  def chart_dett
    @data["CUSTOM"]={}
    data=@data["CUSTOM"]
    #Group.where(group_type: @group_type).each{|g| @groups[g.group_name]||=[] if !g.group_name.blank? ; @groups[g.group_name]<<g.element if !g.group_name.blank?} unless @group_type.blank?
    messages=Message.where(data:  (@date_from..@date_to))
    messages=messages.where(from_type: params[:from_type]) if params[:from_type]
    messages=messages.where(to_type: params[:to_type]) if params[:to_type]
    messages=messages.where(message_type:  params[:message_type]) if params[:message_type]



    @bar = LazyHighCharts::HighChart.new('column') do |f|
      messages.group("data").count("*").each{|k,v| data[k.to_s]=v}
      data.reverse_merge!(@date_hash)
      f.series(:data=>data.keys.sort.map{|x| data[x]})
      f.title({ :text=>""})
      f.options[:xAxis] ={categories: @date_array, labels: {rotation: 270}}
      f.options[:chart][:defaultSeriesType] = "column"
      f.options[:legend]={:floating=> true}
      f.options[:showInLegend]= false
      f.options[:legend]={:floating=> false, layout: "horizontal"}
      f.options[:dataLabels]={:enabled=> false}
      f.plot_options({:column=>{:stacking=>"normal"}})
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

  def live_chart
    oggi=Date.today.to_s
    now=Time.now.advance(:seconds=>Time.now.utc_offset).at_beginning_of_minute
    ultimi_5_min=now.advance(minutes: -(now.min % 5))
    ultimi_5_min= ultimi_5_min.advance(minutes: -5)
    ultime_3_h_in_sec=(ultimi_5_min.advance(hours: -3).to_i)
    #t0=(Time.now.beginning_of_day.to_i+Time.now.utc_offset)
    adesso_in_sec=(ultimi_5_min.to_i)
    ultimi_30_min_in_sec=(ultimi_5_min.advance(minutes: -35).to_i)
    @line = LazyHighCharts::HighChart.new('line_ajax') do |f|

      f.title({text: 'Progressivo ultime 3 h'})
      f.colors(['#2f7ed8','#0d233a','#8bbc21','#910000'])

      #f.subtitle({text: 'Email inviate e ricevute dai server DOMINO della Camera dei Deputati'})
      #f.events({load: 'requestData'})
      f.xAxis({
                  #type: 'linear',
                  type: 'datetime',
                  tickInterval: (30 * 60 * 1000), # 30 minuti
                  tickWidth: 1,
                  gridLineWidth: 1,
                  labels: {align: 'left',x: 3,y: -3}
                  #dateTimeLabelFormats: {month: '%e. %b',year: '%b'}
              })
      f.yAxis([{ #// left y axis
                 title: {text: nil},
                 labels: {align: 'left',x: 3,y: 16,
                     formatter: %|function() {
                    return Highcharts.numberFormat(this.value, 0);
                  }|.js_code
                 },
                 showFirstLabel: false
               },
               { #// right y axis
                 linkedTo: 0,
                 gridLineWidth: 0,
                 opposite: true,
                 title: {text: nil},
                 labels: {align: 'right',x: -3,y: 16,
                     formatter: %|function() {
            return Highcharts.numberFormat(this.value, 0);
          }|.js_code
                 },
                 showFirstLabel: false
               }
              ])
      f.legend({
                   align: 'left',
                   verticalAlign: 'top',
                   y: 20,
                   floating: true,
                   borderWidth: 0
               })
      f.tooltip({
                    enabled:false,
                    shared: true,
                    crosshairs: true
                })


      f.series({
                   name: 'Ricevuti da internet',
                   lineWidth: 2,
                   marker: {radius: 2},
                   data: ultime_3_h_in_sec.step(adesso_in_sec, 60*15).map{|d|
                     d1=DateTime.strptime(d.to_s,'%s')
                     [d*1000, Message.where(["data=:oggi and time <= :d1 and message_type in (:message_type) ",
                                             oggi: oggi, d1: d1, message_type: MESSAGE_TYPE_IN_INTERNET]).count("*")] #"Ricevuti"
                   },
                   point: {
                     events: {
                         click: %|function(e) {
                            var message = Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', this.x) + ' ->  ' + this.series.name + ': '+ this.y;
                            $('#message_out').append(message + '</br>')
                            alert(message);
                              }|.js_code
                              }
                          }
              })
      f.series({
                   name: 'Inviati verso internet',
                   lineWidth: 2,
                   marker: {radius: 2},
                   data: ultime_3_h_in_sec.step(adesso_in_sec, 60*15).map{|d|
                     d1=DateTime.strptime(d.to_s,'%s')
                     [d*1000, Message.where(["data=:oggi and time <= :d1 and message_type in (:message_type) ",
                                             oggi: oggi, d1: d1, message_type: MESSAGE_TYPE_OUT_INTERNET]).count("*")] #"Ricevuti"
                   },
                   point: {
                       events: {
                           click: %|function(e) {
                            var message = Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', this.x) + ' ->  ' + this.series.name + ': '+ this.y;
                            $('#message_out').append(message + '</br>')
                            alert(message);
                              }|.js_code
                       }
                   }
               })
      f.series({
                   name: 'Scambiati nel dominio CAMERA',
                   lineWidth: 2,
                   marker: {radius: 2},
                   data: ultime_3_h_in_sec.step(adesso_in_sec, 60*15).map{|d|
                     d1=DateTime.strptime(d.to_s,'%s')
                     [d*1000, Message.where(["data=:oggi and time <= :d1 and message_type in (:message_type) ",
                                             oggi: oggi, d1: d1, message_type: (MESSAGE_TYPE_IN_CAMERA + MESSAGE_TYPE_OUT_CAMERA )]).count("*")] #"Ricevuti"
                   } ,
                   point: {
                       events: {
                           click: %|function(e) {
                            var message = Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', this.x) + ' ->  ' + this.series.name + ': '+ this.y;
                            $('#message_out').append(message + '</br>')
                            alert(message);
                              }|.js_code
                       }
                   }
               })
          f.series({
                   name: 'Scambiati con il SENATO',
                   lineWidth: 2,
                   marker: {radius: 2},
                   data: ultime_3_h_in_sec.step(adesso_in_sec, 60*15).map{|d|
                     d1=DateTime.strptime(d.to_s,'%s')
                     [d*1000, Message.where(["data=:oggi and time <= :d1 and message_type in (:message_type) ",
                                             oggi: oggi, d1: d1, message_type: ( MESSAGE_TYPE_IN_SENATO+MESSAGE_TYPE_OUT_SENATO)]).count("*")] #"Ricevuti"
                   },
                   point: {
                       events: {
                           click: %|function(e) {
                            var message = Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', this.x) + ' ->  ' + this.series.name + ': '+ this.y;
                            $('#message_out').append(message + '</br>')
                            alert(message);
                              }|.js_code
                       }
                   }
               })


    end

    @line2=[]

    [["Ricevuti da internet", MESSAGE_TYPE_IN_INTERNET,'#2f7ed8' ],
    ["Inviati verso internet", MESSAGE_TYPE_OUT_INTERNET,'#0d233a'],
     ["interni camera.it", (MESSAGE_TYPE_IN_CAMERA+MESSAGE_TYPE_OUT_CAMERA),'#8bbc21'],
     ["interni senato.it", (MESSAGE_TYPE_IN_SENATO+MESSAGE_TYPE_OUT_SENATO),'#910000'],
    ].each do |p|
        @line2 << LazyHighCharts::HighChart.new('line_ajax') do |f|
          f.title({text: "#{p[0]}"})
          f.colors([p[2]])
          f.chart({type: "area", height: 150, width: 280, spacingBottom: 10,spacingTop: 1, spacingLeft: 20, spacingRight: 10})
          f.xAxis({type: 'datetime',
                   tickInterval: (5 * 60 * 1000), # 30 minuti
                   tickWidth: 1,
                   gridLineWidth: 1,
                   labels: {align: 'left',x: -15,y: 10}})
          f.yAxis({title: {text: nil},
                   #tickInterval: 100,
                   tickWidth: 1,
                   labels: {align: 'left',x: -20,y: 15,formatter: %|function() {
                        return Highcharts.numberFormat(this.value, 0);
                      }|.js_code},
                   showFirstLabel: false})
          f.legend({enabled: false,
                    align: 'left',
                    verticalAlign: 'top',
                    y: 20,
                    floating: true,
                    borderWidth: 0})
          f.tooltip({ enabled:false,shared: true,crosshairs: true})
          f.series({name: p[0],step: "center",
                    lineWidth: 1,
                    marker: {radius: 1},
                    data: ultimi_30_min_in_sec.step(adesso_in_sec, 60*5).map{|d|
                      d1=DateTime.strptime(d.to_s,'%s')  #l'intervallo riconvertito in data
                      [d*1000,Message.where(["data=:oggi and time between :d1 and :d2 and message_type in (:message_type) ",
                                         oggi: oggi, d1: d1.advance(minutes:-5), d2: d1, message_type: p[1]]).count("*")]},
                    point: {
                        events: {
                            click: %|function(e) {
                            var message = Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', this.x - (5*60*1000) ) + '/'+ Highcharts.dateFormat('%H:%M:%S', this.x) + ' ->  ' + this.series.name + ': '+ this.y;
                            $('#message_out').append(message + '</br>')
                            alert(message);
                              }|.js_code
                        }
                    }
                    })
          end
      end






   # render :layout=>"live_chart"
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
