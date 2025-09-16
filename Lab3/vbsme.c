#include <stdio.h>
#include <stdlib.h>
#include <math.h>



// int sad(int* window, int* frame, int fRow, int fCol){
//     int sum;
//     for(int i = 0; i < fCol, i++;){
//         for(int j = 0; j < fRow; j++){
//         //sum = abs(window[i] - frame[i]);
        
//     }     
//     }
//     return sum;
// }


//i = col index, j = row index


int convert2dTo1dIndex(int col, int i, int j){
    int row1d = col * j;
    int index1d = row1d + i;
    return index1d; 
}

void diagSearch(int col,int  row){
    int i = 0;
    int j = 0;
    int polarity = 1;
    int rowEvenOrOdd = 0;
    int colEvenOrOdd = 0;
    if(row % 2 == 1)
        rowEvenOrOdd = 1;
    if(col % 2 == 0)
        colEvenOrOdd = 1;
    
    while(i < col && j < row){
        printf( "(%d, %d) ", i, j);
        
        if( j == row - 1 && i % 2 == rowEvenOrOdd){
            i += 1;
            polarity *= -1;
        }
        else if(i == col - 1 && j % 2 == colEvenOrOdd){
            j += 1;
            polarity *= -1;
        }
        else if(j == 0 && i % 2 == 0){
            i += 1;
            polarity *= -1;
        }
        else if(i == 0 && j % 2 == 1){
            j += 1;
            polarity *= -1;
        }
        
        
        else{
            i += 1 * polarity;
            j += -1 * polarity;

        }
    
    }
    
    
}


int main(void){
    diagSearch(8, 8);

}