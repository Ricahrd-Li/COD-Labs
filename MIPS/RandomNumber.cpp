#include<cstdlib>
#include<cstdio> 
using namespace std;
//生成begin--begin+x内的int
int Rand(int x, int begin = 0) {
	return begin + (rand() % x);
}
int main(){
    FILE* fp=fopen("random.txt", "w");
    for(int i=0;i<999;i++){
        fprintf(fp, "%d", Rand(1000));
        fwrite("\n",sizeof(char),1,fp);
    }
}

