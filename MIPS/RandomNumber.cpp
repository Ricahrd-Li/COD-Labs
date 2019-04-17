#include<cstdlib>
#include<cstdio> 
#include<time.h>
using namespace std;
//生成begin--begin+x内的int
int Rand(int x, int begin = 0) {
	return begin + (rand() % x);
}
int main(){
    srand((int)time(0));  // important！
    FILE* fp=fopen("random.txt", "w");
    for(int i=0;i<=999;i++){
    	if(i<999){
	        fprintf(fp, "%d", Rand(1000));
	        fwrite(",",sizeof(char),1,fp);
		}
		else  fprintf(fp, "%d", Rand(1000));
        
    }
}

