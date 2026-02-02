#include <cmath>
#include <vector>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <algorithm>
#include <string>
#include <cstring>
#include <map>
#include <fstream>
#include <time.h>
#include <unistd.h>
#include "BOBHASH32.h"
#include "params.h"
#include "BaseSketch.h"
#include "ssummary.h"
#include "WisePIFinder.h"

using namespace std;
using namespace sketch;

struct Packet{
    string dat;
    ts_t timestamp;
    bool operator < (const Packet&b) const {
        return timestamp < b.timestamp;
    }
};

map <string ,int> B,C;
vector <string> PISketchResult; //mzx
map <string , map<int, int>> W;
struct node {string x;int y;} p[32000005];
//ifstream fin("../../real_data/1.dat",ios::in|ios::binary);
string s[32000005];
char Buf[105];
int cmp(node i,node j) {return i.y>j.y;}



enum class func_type {
    ASKETCH, WisePIFinder, CUCKOOCOUNTER, ELASTIC, HEAVYKEEPER, LOSSYCOUNTING, MVSKETCH, NITROSKETCH, SPACESAVING
};

std::vector<std::string> func_names;

std::map<std::string, int> AAE;
std::map<std::string, double> ARE;
std::map<std::string, int> _sum;
std::map<std::string, double> _throughput;

map<std::string, int> PIflow;
map<std::string, int> ResPIflow;

std::vector<BaseSketch*> func;

int main(int argc, char** argv)
{
    int MEM=400,K=1000;
    int c;
    char dataset[40]={'\0'};
    while((c=getopt(argc, argv, "d:m:k:"))!=-1) {
        switch(c) {
            case 'd':
                strcpy(dataset,optarg);
                break;
            case 'm':
                MEM=atoi(optarg);
                break;
            case 'k':
                K=atoi(optarg);
                break;
        }
    }
    cout<<"MEM="<<MEM<<"KB"<<endl<<"Find PF flows " <<endl<<endl;
    cout<<"preparing all algorithms"<<endl;
    int m=MAX_INSERT;  // the number of flows

    int CS_M;
    // ID Windows average counter
    for (CS_M = 1;  ((4 + 4 + 2 + 2) * MAX_ENTRY * CC_d)  * CS_M  <= MEM * 1024; CS_M++); if (CS_M % 2 == 0) CS_M--;
 
    std::cout << "WisePIFInder+ maxBucketNum: " << CS_M << std::endl;

    func.push_back(new WisePIFinder(CS_M));
   
    // prepare clear
    for (auto &iter : func) {
        func_names.push_back(iter->get_name());
        iter->clear();
    }


    // Inserting
	timespec time1, time2;
	long long resns;

	cout<<"dataset: "<<dataset<<endl<<endl;
	ifstream fin(dataset, ios::in|ios::binary);
	if(!fin) 
    {
        printf("Dataset not exists!\n");return -1;
    }

    printf("\n*************prepare PF flow************\n");
    std::cout << "Time Windows Max num: " << (m-1)/TimeWindosPara + 1<< std::endl;

    Packet* P = new Packet[m];

    /*read packet and sort by timestamp */
	for (int i = 0; i < m; i++)
	{
		fin.read(Buf, KEY_LEN + sizeof(ts_t));
        char destination[KEY_LEN + 1] = {0};
        strncpy(destination, Buf, KEY_LEN);
        P[i].dat = destination; 
        P[i].timestamp = *(ts_t*)(Buf + KEY_LEN);   
  
    }
    sort(P, P + m);

    /*caculate time para*/
    ts_t current_time = 0;
    ts_t total_time = 0;

    total_time = P[m-1].timestamp - P[0].timestamp;
    current_time = P[0].timestamp;
    current_cycle_time = P[0].timestamp;
    time_tread = total_time / TimeWindosPara;
    cerr<<"tot Time: " << total_time <<" time_windows: "<< time_tread << endl;

    /* Calculate the distribution of flow */
    int wNum = 1;
    for (int i = 0; i < m; i++)
	{     
        s[i] = P[i].dat;
		B[s[i]]++;

        if (P[i].timestamp - current_time > time_tread)
        {
            wNum ++ ;
            current_time += time_tread;
        }  
        if (W.find(s[i]) == W.end())
        {
            /*new*/
            W[s[i]].insert(std::make_pair(wNum, 1));
        }else{
            if (W[s[i]].find(wNum) == W[s[i]].end())
            {
                /*exist, but new window*/
                W[s[i]].insert(std::make_pair(wNum, 1));
            }else{
                W[s[i]][wNum]++;
            }   
        }  
	}

    /* label PF flow*/
    string flowId = "";
    int TimeWindows = 0;
    
    int test_N = 0;
    bool over = false;
    for (const auto& pair : W) {
        //std::cout << "ID: " << i << " , Time Windows: " << pair.first << ", Counter: " << pair.second << std::endl;
        flowId = pair.first;
        TimeWindows = pair.second.size();
        if(TimeWindows < persitTimeWindows){
            continue;
        }

        float sum = 0;
        float averageReal = B[flowId] / (TimeWindows + 0.0);

        if (averageReal < ave_threshold){
            continue;
        }
        
        // over = false;
        // for (const auto& pair2 : pair.second){
        //     if(pair2.second < threshold){
        //         over = true;
        //         break;
        //     }
        // }

        // if(over){
        //     continue;
        // }
    
        PIflow[flowId] = TimeWindows;
    }

    std::cout << "Total flow size " <<  B.size() << std :: endl;   
    std::cout << "PF flow size " <<  PIflow.size() << std :: endl; 

    
    int testPI = 0;
    int testW = 0;
    for (const auto& pair : PIflow) {
    //std::cout << "ID: " << i << " , Time Windows: " << pair.first << ", Counter: " << pair.second << std::endl;
        flowId = pair.first;
        TimeWindows = pair.second;
        testW = W[flowId].size();
        if (TimeWindows == testW)
        {
            testPI ++ ;
            //printf(" TimeWindows: %d; total sum : %d", TimeWindows, B[flowId]);
        }
        
    }

	printf("\n*************throughput************\n");
    std::cout << "flow_sum: " << m << std::endl;

    for (auto &sketch_func : func) {
        // if (sketch_func->get_name() == "WisePIFinder") continue;
        clock_gettime(CLOCK_MONOTONIC, &time1);
        for (int i = 1; i <= m; i++) {
            //sketch_func->Insert(s[i]);
            packet_time = P[i].timestamp;
            sketch_func->Insert(P[i].dat);
        }
        clock_gettime(CLOCK_MONOTONIC, &time2);
	    resns = (long long)(time2.tv_sec - time1.tv_sec) * 1000000000LL + (time2.tv_nsec - time1.tv_nsec);
        double throughput = (double)1000.0 * m / resns;
        printf("throughput of %s (insert): %.6lf Mips\n", sketch_func->get_name().c_str(), throughput);
        _throughput[sketch_func->get_name()] = throughput;
    }

    for (auto &sketch_func : func) {
        std::cout << sketch_func->get_name() << " work" << std::endl;;
        sketch_func->work();
    }

    printf("\npreparing true flow\n");
	// preparing true flow
	int cnt=0;
    for (map <string,int>::iterator sit=B.begin(); sit!=B.end(); sit++)
    {
        p[++cnt].x=sit->first;
        p[cnt].y=sit->second;
    }
    
    // Calculating PRE, ARE, AAE
    std::cout << "Calculating\n" << std::endl;
    
    int test = 0;
    for (auto &sketch_func : func) {
        // if (sketch_func->get_name() == "WisePIFinder") continue;
        std::string str;
        uint32_t num;
        int w_N = 0;
        
        cout << "sketch flow: " << res_count << endl;
        for (int i = 0; i < res_count; i++) {
            auto [str, num] = sketch_func->Query(i);

            auto itW = W.find(str);
            if(itW != W.end()){
                w_N = W[str].size();
                //printf("total: ID = %ld, sketch Windows = %d, real Windwos = %d\n", itW, num, w_N);
            }

            ARE[sketch_func->get_name()] += abs(w_N - num) / (w_N + 0.0);
            AAE[sketch_func->get_name()] += abs(w_N - num);
            //AAE[sketch_func->get_name()] += abs(B[str] - num);
            //ARE[sketch_func->get_name()] += abs(B[str] - num) / (B[str] + 0.0);
            // if (sketch_func->get_name() == "WisePIFinder") {
            //     if (B[str] != num) {
            //         std::cout << B[str] << "\t" << num << "\t" << B[str] - num << std::endl;
            //     }
            // }
            if (C[str]) {
                _sum[sketch_func->get_name()]++;
            }
        }
        
        printf("%s:\n", sketch_func->get_name().c_str());
        //printf("\tAccepted: %d/%d %.10f\n", _sum[sketch_func->get_name()], K, (_sum[sketch_func->get_name()] / (K + 0.0)));
        printf("\tARE: %.10f\n", ARE[sketch_func->get_name()] / (res_count + 0.0));
        printf("\tAAE: %.10f\n\n", AAE[sketch_func->get_name()] / (res_count + 0.0));
    }

    /*caculate F1 */
    std::cout << "Calculating F1" << std::endl;
    float Precision, Recall, f1;
    int counterPrec = 0;
    int sumWin = 0;
    //double ARE2 = 0.0;
    for (auto &sketch_func : func) {
        for (int i = 0; i < res_count; i++) {
            auto [str, num] = sketch_func->Query(i);
            auto it = PIflow.find(str);
            if(it != PIflow.end()){
                //printf("PI flow ID = %ld, sketch Windows = %d, real Windwos = %d\n", it, num, PIflow[str]);
                //ARE2 += abs(PIflow[str] - num) / (PIflow[str] + 0.0);
                counterPrec ++ ; 
                // if(PIflow[str] == W[str].size()){
                //     test2 ++;
                // }

                auto res = ResPIflow.find(str);
                if(res == ResPIflow.end())
                {
                    ResPIflow[str] = num;
                }
            }
        }
    }

    //cout << "sketch PI flow, Precision: " <<counterPrec << endl;
    //cout << "Remove duplicates PI flow:check: " << ResPIflow.size() << endl;
    printf("\t sketch PI flow, Precision: %d\n", counterPrec);
    //printf("\t PI sketch ARE: %.10f\n\n", ARE2 / (counterPrec + 0.0));
    
    Precision = counterPrec / (res_count + 0.0);
    Recall = counterPrec / (PIflow.size() + 0.0);
    f1 = 2.0 * Precision * Recall / (Precision + Recall);
    printf("Precision: %f, Recall:%f, f1:%f\n \n", Precision, Recall, f1);

    string resultFile = "result.csv";
    
    return 0;
}
