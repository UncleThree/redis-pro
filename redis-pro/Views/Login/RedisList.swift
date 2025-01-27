//
//  RedisInstanceList.swift
//  redis-pro
//
//  Created by chengpanwang on 2021/1/25.
//

import SwiftUI
import Logging

func onAppear() {
    print("list on appear。。。")
}

struct RedisList: View {
    @EnvironmentObject var redisInstanceModel:RedisInstanceModel
    @EnvironmentObject var globalContext:GlobalContext
    @StateObject var redisFavoriteModel: RedisFavoriteModel = RedisFavoriteModel()
    @State private var showFavoritesOnly = false
    @State private var selectedRedisModelId: String?
    @AppStorage("User.defaultFavorite")
    private var defaultFavorite:String = "last"
    
    let logger = Logger(label: "redis-login")
    
    var quickRedisModel:[RedisModel] = [RedisModel](repeating: RedisModel(name: "QUICK CONNECT"), count: 1)
    
    var selectRedisModel: RedisModel {
        redisFavoriteModel.redisModels.first(where: { $0.id == selectedRedisModelId }) ?? RedisModel()
    }
    
    var filteredRedisModel: [RedisModel] {
        redisFavoriteModel.redisModels
    }
    
    var body: some View {
        HSplitView {
            VStack(alignment: .leading,
                   spacing: 0) {
                
                List(selection: $selectedRedisModelId) {
                    ForEach(quickRedisModel) { redisModel in
                        RedisQuickRow(redisModel: redisModel)
                            .listRowInsets(EdgeInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0)))
                    }
                    
                    Section(header: Text("FAVORITES")) {
                        ForEach(filteredRedisModel) { redisModel in
                            RedisRow(redisModel: redisModel)
                                .tag(redisModel.id)
                                .contentShape(Rectangle())
                                .gesture(TapGesture(count: 2).onEnded {
                                    onConnect()
                                })
                                .simultaneousGesture(TapGesture().onEnded {
                                    self.selectedRedisModelId = redisModel.id
                                })
                        }
                    }
                    .collapsible(false)
                    
                }
                .listStyle(PlainListStyle())
                .padding(.all, 0)
                
                
                // footer
                HStack(alignment: .center) {
                    MIcon(icon: "plus", fontSize: 13, action: onAddAction)
                    MIcon(icon: "minus", fontSize: 13, disabled: selectedRedisModelId == nil, action: onDelAction)
                    
                }
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            }
            .padding(0)
            .frame(minWidth:180, idealWidth: 180, maxWidth: .infinity)
            .layoutPriority(0)
            .onAppear{
                logger.info("load all redis favorite list")
                redisFavoriteModel.loadAll()
                selectFavoriteRedisModel()
            }
            
            VStack{
                Spacer()
                HStack {
                    Spacer()
                    LoginForm(redisFavoriteModel: redisFavoriteModel, redisModel: selectRedisModel)
                    Spacer()
                }
                Spacer()
            }
            .frame(minWidth: 500, idealWidth:500, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
            .layoutPriority(1)
        }
    }
    
    func selectFavoriteRedisModel() -> Void {
        if defaultFavorite == "last" {
            DispatchQueue.main.async {
                self.selectedRedisModelId = self.redisFavoriteModel.lastRedisModelId
            }
        } else {
            self.selectedRedisModelId = defaultFavorite
        }
    }
    
    func onAddAction() -> Void {
        logger.info("add new redis favorite action")
        redisFavoriteModel.save(redisModel: RedisModel())
    }
    func onDelAction() -> Void {
        logger.info("del redis favorite action, id:\(String(describing: selectedRedisModelId))")
        if selectedRedisModelId == nil {
            return
        }
        
        let nextId:String? = redisFavoriteModel.delete(id: selectedRedisModelId!)
        selectedRedisModelId = nextId
    }
    
    func onConnect() -> Void {
        let _ = redisInstanceModel.connect(redisModel:selectRedisModel).done({r in
            redisFavoriteModel.saveLast(redisModel: selectRedisModel)
            logger.info("on connect to redis server successed: \(selectRedisModel)")
        })
    }
}


struct RedisInstanceList_Previews: PreviewProvider {
    private static var redisFavoriteModel: RedisFavoriteModel = RedisFavoriteModel()
    static var previews: some View {
        RedisList()
            .environmentObject(redisFavoriteModel)
            .onAppear{
                redisFavoriteModel.loadAll()
            }
        
    }
}
