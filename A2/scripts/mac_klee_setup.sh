#!/bin/bash

echo "=========================================="
echo "KLEE Setup for MacBook M2"
echo "SENG3320/6320 Assignment 2 Part 2"
echo "=========================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Installing Docker Desktop for Mac..."
    echo "📥 Please install Docker Desktop manually:"
    echo "   1. Download from: https://www.docker.com/products/docker-desktop/"
    echo "   2. Or install via Homebrew: brew install --cask docker"
    echo "   3. Start Docker Desktop application"
    echo "   4. Run this script again"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

echo "✅ Docker is available and running"

# Create working directory
mkdir -p klee-work
cd klee-work

# Copy triangle.c to working directory if it exists
if [ -f "../src/triangle.c" ]; then
    cp ../src/triangle.c .
    echo "✅ Copied triangle.c to KLEE working directory"
else
    echo "📝 Creating triangle.c..."
    cat > triangle.c << 'EOF'
#include <klee/klee.h>
#include <stdio.h>
#include <assert.h>

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
    
    klee_make_symbolic(&a, sizeof(a), "a");
    klee_make_symbolic(&b, sizeof(b), "b");
    klee_make_symbolic(&c, sizeof(c), "c");
    
    klee_assume(a > 0 && a <= 100);
    klee_assume(b > 0 && b <= 100);
    klee_assume(c > 0 && c <= 100);
    
    triangle(a, b, c);
    
    return 0;
}
EOF
    echo "✅ Created triangle.c with KLEE instrumentation"
fi

# Pull KLEE Docker image
echo "📥 Downloading KLEE Docker image (this may take a few minutes)..."
docker pull klee/klee:2.3

if [ $? -ne 0 ]; then
    echo "❌ Failed to download KLEE Docker image"
    exit 1
fi

echo "✅ KLEE Docker image downloaded successfully"

# Test KLEE setup
echo "🧪 Testing KLEE setup..."
docker run --rm -v $(pwd):/home/klee/work -w /home/klee/work klee/klee:2.3 /bin/bash -c "
    echo 'Testing KLEE compilation...'
    clang -I /usr/include -emit-llvm -c -g -O0 -Xclang -disable-O0-optnone triangle.c
    
    echo 'Testing KLEE execution...'
    timeout 30s klee --libc=uclibc --posix-runtime triangle.bc
    
    echo 'KLEE test completed successfully!'
    echo 'Generated test cases:'
    ls klee-last/*.ktest | wc -l
"

if [ $? -eq 0 ]; then
    echo "✅ KLEE setup test completed successfully!"
    
    # Show sample output
    echo ""
    echo "📊 Sample KLEE output:"
    docker run --rm -v $(pwd):/home/klee/work -w /home/klee/work klee/klee:2.3 /bin/bash -c "
        for f in klee-last/*.ktest; do
            echo '--- Test case: \$f ---'
            ktest-tool \"\$f\"
            break
        done
    "
    
else
    echo "❌ KLEE setup test failed"
    echo "💡 Check Docker setup and try again"
    exit 1
fi

cd ..

echo ""
echo "=========================================="
echo "✅ KLEE setup completed for MacBook M2!"
echo "=========================================="
echo "📋 Setup Summary:"
echo "   ✅ Docker Desktop running"
echo "   ✅ KLEE Docker image downloaded"
echo "   ✅ triangle.c prepared with KLEE instrumentation"
echo "   ✅ KLEE test execution successful"
echo ""
echo "🚀 Ready to run assignment:"
echo "   ./scripts/run_mac.sh"
echo ""
echo "📁 KLEE work directory: klee-work/"
echo "=========================================="