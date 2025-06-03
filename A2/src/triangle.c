#include <klee/klee.h>
#include <stdio.h>
#include <assert.h>

/* The Triangle program, which determines if three inputs specify an equilateral
   triangle, an isosceles triangle, an ordinary triangle, or a non-triangle. */
void triangle(int a, int b, int c) {
    printf("Input: a=%d, b=%d, c=%d\n", a, b, c);
    
    if ((a + b > c) && (a + c > b) && (b + c > a)) {
        if (a == b || a == c || b == c) {
            if (a == b && a == c) {
                printf("equilateral triangle.\n");
            } else {
                printf("isosceles triangle.\n");
            }
        } else {
            printf("triangle.\n");
        }
    } else {
        printf("non-triangle.\n");
    }
    return;
}

int main() {
    int a, b, c;
    
    // Make the inputs symbolic
    klee_make_symbolic(&a, sizeof(a), "a");
    klee_make_symbolic(&b, sizeof(b), "b");
    klee_make_symbolic(&c, sizeof(c), "c");
    
    // Add constraints to make inputs reasonable (positive integers)
    klee_assume(a > 0 && a <= 100);
    klee_assume(b > 0 && b <= 100);
    klee_assume(c > 0 && c <= 100);
    
    triangle(a, b, c);
    
    return 0;
}