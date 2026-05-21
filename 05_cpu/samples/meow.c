typedef unsigned short uint16_t;
typedef unsigned long uint32_t;

#define FIB_ADDR ((volatile uint16_t *)0x20u)

#define FREQ 20'000'000
// #define FREQ 2

#define SLEEP_N FREQ

static void sleep_busy(unsigned int n)
{
    volatile uint32_t i;

    for (i = 0; i < n; i++) {
        /* Busy wait */
    }
}

int main(void)
{
    uint16_t fib_prev = 1;
    uint16_t fib_curr = 2;

    while (1) {
        uint16_t fib_next;

        *FIB_ADDR = fib_prev;
        sleep_busy(SLEEP_N);

        fib_next = fib_prev + fib_curr;
        fib_prev = fib_curr;
        fib_curr = fib_next;
    }

    /* Never reached */
}