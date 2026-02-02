#ifndef _WISE_PI_FINDER_H
#define _WISE_PI_FINDER_H

// #define TEST
#define CHECK_TOP
#ifndef CHECK_TOP
    #define TOP 2
#endif

#include <stdint.h>
#include <algorithm>
#include <functional>
#include <vector>
#include <cmath>
#include <limits.h>
#include <iostream>

#include "LossyStrategy.h"
#include "BaseSketch.h"
#include "BOBHASH64.h"


using namespace std;

namespace sketch {
const int MAX_ROW = 2;
const int MAX_ENTRY = 4;

//new add
uint64_t sum_flow = 0;
//unifiedCounterBucket _uniCountBucket;

// unifiedCounterStaus
const int unifiedCounterOver = 0; 
const int unifiedCounterAdd = 1;

// the num of per window

const uint8_t ave_threshold = 20; 
const uint8_t threshold = 10;  // packet number per window
const uint8_t persitTimeWindows = MAX_INSERT * 0.1; 

const uint8_t sma_n_thread = 10;
const uint32_t sma_counter = 500;

const int TimeWindosPara = 1000; 
int res_count = 0;

// packet time
ts_t packet_time = 0.0;
ts_t current_cycle_time = 0.0;
ts_t time_tread = 0.0;
uint16_t sma_n = 0;



// on-off
int* OnOffArray = nullptr; 

class unifiedCounterEntry {
public:
    unifiedCounterEntry(): flag(0), count(0), average(0.0), variance(0){}
    void clear() {
        flag = 0;
        count = 0;
        average = 0.0;
        variance = 0;
    }

    void clear_flag() {
        flag = 0;
    }
    
    void update(uint32_t n_window) {
       // cout << "average && variance" << endl;
        //cout << "average && variance" << average << variance << endl;
        average = (n_window * average + count) / (n_window + 1);
        //variance = 0;
        //variance = (n_window * ( std::pow(variance_pre, 2) + std::pow((average_pre - average), 2))  + std::pow((count - average),2) / (n_window + 1));
        
        
        flag = 1;
        count = 0;
    }

    bool new_window() {
        return flag == 0;
    }

// private:
    uint8_t flag;
    uint16_t count;
    //uint16_t count;
    float average;
    int32_t variance;
};


class unifiedCounterBucket {
public:
    unifiedCounterBucket() {
    }

    void resize(int bucketNum){
        maxEntryNum = bucketNum * MAX_ENTRY;
        unifiedCounterEntrys.resize(maxEntryNum);
    }

    int check(int i) {

        /* code */
        unifiedCounterEntrys[i].clear_flag();
        if(unifiedCounterEntrys[i].average > threshold){
            return i;
        } 
        return 0;
    }
    
    bool insertUniCounter(int position, uint32_t n_window) {

        bool insertStatus = true;

        
        // if(unifiedCounterEntrys[position].average < ave_threshold){
        //     unifiedCounterEntrys[position].flag = 1;
        //     insertStatus = false;    
        //     return insertStatus;
        // }

        
        //if(OnOffArray[position] == 0){ //mzx 20241106
        if(unifiedCounterEntrys[position].new_window()){
            
            unifiedCounterEntrys[position].update(n_window);
          
            // if(position == 24638){
            //     printf("pre: counter = %d, average = %f, total+pow = %f\n", count, average, variance);
            //     printf("after:  average = %f, total_pow = %f\n", unifiedCounterEntrys[position].average, unifiedCounterEntrys[position].variance);
            // }

        }

        ++ unifiedCounterEntrys[position].count;

        //uint8_t cnt = unifiedCounterEntrys[position].count;
        
        // if(insertStatus){
        //     ++ unifiedCounterEntrys[position].count;
        // }

        return insertStatus;

    }


// private:
    std::vector<unifiedCounterEntry> unifiedCounterEntrys;
    int maxEntryNum; 
};


class resEntry {
public:
    resEntry(): ID(""), count(0), Coefficient(0) {}
    //resEntry(const std::string &id, uint8_t fp, uint32_t cnt): ID(id), average(fp), count(cnt) {}
    void clear() {
        ID = "";
        count = 0;
        Coefficient = 0.0;
    }

// private:
    std::string ID;
    uint32_t count;
    float Coefficient;
};

class entry {
public:
    entry(): ID(""), fingerprint(0), count(0) {}
    entry(const std::string &id, uint16_t fp, uint32_t cnt): ID(id), fingerprint(fp), count(cnt) {}
    void clear() {
        ID = "";
        fingerprint = 0;
        count = 0;
    }

    bool full(int level, int cnt = 1) {
        if ((level == 3 || level == 4) && count > 0xf - cnt) {
            return true;
        }
        if (level == 2 && count > 0xff - cnt) {
            return true;
        }
        if (level == 1 && count > 0xffff - cnt) {
            return true;
        }
        return false;
    }

    bool empty() {
        return count == 0;
    }

    bool equal(uint16_t fp) {
        return fp == fingerprint;
    }

    bool equal_id (string flowId) {
        return flowId == ID;
    }

    bool operator==(const entry &e) const {
        return fingerprint == e.fingerprint;
    }

    bool operator<(const entry &e) const {
        return count > e.count;
    }

// private:
    std::string ID;
    uint16_t fingerprint;
    uint32_t count;
};

class Bucket {
public:
    Bucket() {
        entries.resize(MAX_ENTRY);
    }
    void clear() {
        entries.clear();
        entries.resize(MAX_ENTRY);
        // entries.resize(5)
    }

    void bucket_sort(int entry_index) {
        while (entry_index > 0 && entries[entry_index].count > entries[entry_index - 1].count) {
            std::swap(entries[entry_index], entries[entry_index - 1]);
            entry_index--;

        }
    }
    
    bool Insert(entry &cur_entry) {
        if (cur_entry.count > entries[0].count) {
            int entry_index = 4;
            while (entry_index > 0) {
                entries[entry_index] = entries[entry_index - 1];
                // entries[entry_index] = std::move(entries[entry_index - 1]);
                --entry_index;
            }
            entries[0] = cur_entry;
            return true;
        }
    }
    
    bool Insert(uint16_t fp, const std::string &id, Bucket *next_bucket) {
        for (int i = 0; i < MAX_ENTRY; i++) {
            if (entries[i].empty()) {
                #ifdef CHECK_TOP
                if (i == 0) {
                #endif
                    entries[i].ID = id;
                #ifdef CHECK_TOP
                }
                #endif
                entries[i].fingerprint = fp;
                entries[i].count = 1;
                return true;
            }
            if (entries[i].equal(fp)) {
                // judge full
                // if (entries[i].full(i, 1)) {
                //     cout << "out of flow" << entries[i].count << endl;
                //     // return false;
                // }
                ++entries[i].count;
                #ifdef TEST
                if (i != 0 && entries[i].count > 125 && next_bucket->entries[0].count < entries[i].count) {
                    cout << entries[i].count << " " << next_bucket->entries[0].count << endl;
                }
                #endif
                bucket_sort(i);
                return true;
            }
        }
        return false;
    }

    bool l2Kick(int &threshold1, double &threshold2) {
        if (entries[0].count >= threshold1 &&
            entries[1].count >= entries[0].count * threshold2) {
            return true;
        }
        return false;
    }

    void remove(int entry_index) {
        while (entry_index + 1 < MAX_ENTRY) {
            // entries[entry_index] = entries[entry_index + 1];
            entries[entry_index] = std::move(entries[entry_index + 1]);
            ++entry_index;
        }
    }

// private:
    std::vector<entry> entries;
};

class WisePIFinder : public sketch::BaseSketch {
public:
    //WisePIFinder(int threshold1, double threshold2, int maxBucketNum, int K);
    WisePIFinder(int maxBucketNum)
    {
    _bobHash = new BOBHash64(1005);
    _buckets.resize(MAX_ROW, vector<Bucket>(maxBucketNum)); //100KB K=100 ÊýÁ¿3125
    _bucket_num = maxBucketNum;
    _lossy_func = Lossy::MinusOneStrategy{};
    _uniCountBucket.resize(MAX_ROW * _bucket_num);
    }
    
    // WisePIFinder(int threshold1, double threshold2, int totMemory);
    ~WisePIFinder();
    void Insert(const std::string &str);
    std::pair<std::string, int> Query(int k);
    void work();
    void clear();
    std::string get_name();
    
private:
    uint64_t Hash(const std::string &str);
    int _bucket_num;

    BOBHash64 *_bobHash;
    vector<vector<Bucket>> _buckets;
    Lossy::BaseStrategy *_lossy;
    std::function<void(uint32_t &)> _lossy_func;
    std::vector<entry> _ret;
    std::vector<resEntry> _retRes;

    // add
   unifiedCounterBucket _uniCountBucket;
};

uint64_t WisePIFinder::Hash(const std::string &str) {
    return _bobHash->run(str.c_str(), str.size());
}

WisePIFinder::~WisePIFinder() {
}

void WisePIFinder::Insert(const std::string &str) {
    uint64_t hash_key = Hash(str);
    //uint8_t fp = hash_key >> 56;
    //uint16_t fp = hash_key >> 56;
    uint16_t fp = hash_key & 0xFFFF;
    uint64_t keys[2] = {hash_key % _bucket_num, 0};
    keys[1] = (keys[0] ^ fp) % _bucket_num;
    keys[0] %= _bucket_num;

    int insert_i = -1, insert_j;
    bool is_insert = false;
    bool is_empty_postition = false;
    int position = 0;
    uint32_t current_window_nums = 0;
    
    if (packet_time - current_cycle_time > time_tread)
    {

        //std::memset(OnOffArray, 0, 2 * _bucket_num * MAX_ENTRY); //mzx 20241106
        current_cycle_time += time_tread;

        //printf("clear flag! packet time is %ld, current_cycle_time%ld, sum_flow %d\n", packet_time, current_cycle_time, sum_flow);
        for (int i = 0; i < MAX_ROW *_bucket_num * MAX_ENTRY; i++){
            _uniCountBucket.unifiedCounterEntrys[i].clear_flag();
        }
    }
    
    sum_flow ++ ;

    int unifiedCounterEntryPostion = 0;

    for (int i = 0; i < MAX_ROW; ++i) {
        unifiedCounterEntryPostion = 0;

        if (is_insert) {
            break;
        }
        
        for (int j = 0; j < MAX_ENTRY; j++) {
           
            
            unifiedCounterEntryPostion = i * _bucket_num * MAX_ENTRY + keys[i] * MAX_ENTRY + j ;  

            bool newWindows = _uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion].new_window();

            //bool newWindows=false;
            //bool newWindows = OnOffArray[unifiedCounterEntryPostion]; //mzx 20241106
            // if(OnOffArray[unifiedCounterEntryPostion] == 0){
            //     newWindows = true;
            // }
            
            
            //if(_buckets[i][keys[i]].entries[j].equal_id(str))
            if (_buckets[i][keys[i]].entries[j].equal(fp)) 
            { 
                current_window_nums =  _buckets[i][keys[i]].entries[j].count;

                //OnOffArray[unifiedCounterEntryPostion] = 1; //mzx 20241106
                
                _uniCountBucket.insertUniCounter(unifiedCounterEntryPostion, current_window_nums);
                 is_insert = true;

                // if(!insertStatus){
                //     is_insert = true;
                //     break;
                // }  

                if (newWindows){                                       
                    
                    ++_buckets[i][keys[i]].entries[j].count;
                    is_insert = true;
               
                    
                    int entry_index = j;
                    while (j > 0 && _buckets[i][keys[i]].entries[entry_index].count >= _buckets[i][keys[i]].entries[entry_index - 1].count) {
                        if(_buckets[i][keys[i]].entries[entry_index].count > _buckets[i][keys[i]].entries[entry_index - 1].count){
                            std::swap(_buckets[i][keys[i]].entries[entry_index], _buckets[i][keys[i]].entries[entry_index - 1]);
                            std::swap(_uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion], 
                                _uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion - 1]);
                        }
                        else if ((_buckets[i][keys[i]].entries[entry_index].count == _buckets[i][keys[i]].entries[entry_index - 1].count) && 
                        (_uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion].average > _uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion - 1].average))
                        {
                            std::swap(_buckets[i][keys[i]].entries[entry_index], _buckets[i][keys[i]].entries[entry_index - 1]);
                            std::swap(_uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion], 
                                _uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion - 1]);
                        }

                        entry_index--;
                        unifiedCounterEntryPostion --;
                        break;
                    }
                }
                
                break;
            } 
            else if (_buckets[i][keys[i]].entries[j].empty())
            { 
                insert_i = i;
                insert_j = j;
                is_empty_postition = true;
            }

            
            else if(!is_empty_postition && newWindows){
                float average = _uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion].average;
                if (average < 0)
                {
                    insert_i = i;
                    insert_j = j;
                    _uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion].clear();
                    _buckets[i][keys[i]].entries[j].clear();
                    is_empty_postition = true;
                }
            }  
        }
    }
    
    
    if(!is_insert){ 
        
        
        if(is_empty_postition){


            unifiedCounterEntryPostion = insert_i * _bucket_num * MAX_ENTRY + keys[insert_i] * MAX_ENTRY + insert_j ;
            // if(unifiedCounterEntryPostion == 43391)
            //     {
            //        printf("\n is empty !!! clear row = %d, bukket =%d, j = %d\n", insert_i, keys[insert_i], insert_j);
            //        printf("buket fp = %d, windows = %d\n", _buckets[insert_i][keys[insert_i]].entries[insert_j].fingerprint, 
            //        _buckets[insert_i][keys[insert_i]].entries[insert_j].count);
            //     }

            _buckets[insert_i][keys[insert_i]].entries[insert_j].ID = str;
            _buckets[insert_i][keys[insert_i]].entries[insert_j].count = 1;
            _buckets[insert_i][keys[insert_i]].entries[insert_j].fingerprint = fp;

            _uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion].flag = 1;
            _uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion].count = 1;
            _uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion].average = 0;

            //OnOffArray[unifiedCounterEntryPostion] = 1; //mzx 20241106
         }

        
        else
        {
            entry &lossy_entry0 = _buckets[0][keys[0]].entries.back();
            entry &lossy_entry1 = _buckets[1][keys[1]].entries.back();

            
            if (lossy_entry0.count < lossy_entry1.count) {
                
                unifiedCounterEntryPostion = 0 * _bucket_num + keys[0] * MAX_ENTRY + MAX_ENTRY - 1 ;
                _uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion].average -= 0.1;
            }else{
                unifiedCounterEntryPostion = 1 * _bucket_num + keys[1] * MAX_ENTRY + MAX_ENTRY - 1 ;
                _uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion].average -= 0.1;
            }
        }
    }
}


std::pair<std::string, int> WisePIFinder::Query(int k) {
    // modify entry structure and use move
    return std::make_pair(_ret[k].ID, _ret[k].count);
}

void WisePIFinder::work() {
    // #ifdef CHECK_TOP
    // _ret.resize(_bucket_num * MAX_ROW);
    // #endif

    int unifiedCounterEntryPostion;
    float average = 0.0;
    float coefficient = 0.0;

    for (int i = 0; i < MAX_ROW; i++) {
        for (int j = 0; j < _bucket_num; j++) {
            for (int k = 0; k < MAX_ENTRY; k++){
                
                 unifiedCounterEntryPostion = i * _bucket_num * MAX_ENTRY + j * MAX_ENTRY + k ;
          
                //float totoal = _uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion].variance;
                average = _uniCountBucket.unifiedCounterEntrys[unifiedCounterEntryPostion].average;
                
                // if counter// test mzx
                if (average < ave_threshold) //test:mzx 2024 1105
                {
                   continue;
                }
                
                if (_buckets[i][j].entries[k].count < persitTimeWindows ){
                    continue;
                }
                
                // //cacalute variance
                //
                // float thread_variance = ((threshold - average) * (threshold - average) + std::pow(average, 2))/2.0;
                // variance = abs(totoal/_buckets[i][j].entries[k].count - std::pow(average, 2));
                // if(variance > thread_variance){
                //     continue;
                // }

                uint64_t hash_key = Hash(_buckets[i][j].entries[k].ID);
                uint16_t fp = hash_key & 0xFFFF;

                res_count ++ ;
                entry restEntry;
                restEntry.ID = _buckets[i][j].entries[k].ID;
                restEntry.count = _buckets[i][j].entries[k].count;
                
                _ret.push_back(restEntry);
                
                
                //printf("sketch flow: id = %02x, Windows = %d, average = %f \n",  fp, restEntry.count, average);

              
                
            }

        }
    }
                        
    sort(_ret.begin(), _ret.end());
    // sort(_retRes.begin(), _retRes.end(), [](const auto& a, const auto& b){
    //     return a.begin()->second.Coefficient < b.begin()->second.Coefficient;
    // });

    //std::cout << "ret_size: " << _ret.size() << std::endl;
    //std::cout << "ret not empty: " << res_count << std::endl;
    // for (int i = 0; i < _ret.size(); i++) {
    //     cout <<" flow id" << _ret[i].ID << endl;
    //     cout <<" flow windows" << _ret[i].count << endl;
    // }
    
}


void WisePIFinder::clear() {

}

std::string WisePIFinder::get_name() {
    return "WisePIFinder";
}

} // namespace cuckoo_sketch

#endif
