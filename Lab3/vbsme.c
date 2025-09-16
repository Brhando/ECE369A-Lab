#include <stdio.h>
#include <stdlib.h>
#include <math.h>



// int sad(int* window, int* frame, int row, int col){
//     int sum;
//     for(int i = 0; i < row * col, i++;){
//         sum = abs(window[i] - frame[i]);     
//     }
//     return sum;
// }


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
    printf( "(%d, %d) ", i, j);
    }
    
    
}


int main(void){
    diagSearch(6, 5);

}