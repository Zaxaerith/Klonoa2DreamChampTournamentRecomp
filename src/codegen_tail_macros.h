// codegen_tail_macros.h — force-included for generated guest-code TUs.
#pragma once

#ifndef GBARECOMP_TAIL_CALL
#define GBARECOMP_TAIL_CALL(fn)  do { (fn)(); return; } while (0)
#endif
#ifndef GBARECOMP_TAIL_DISPATCH
#define GBARECOMP_TAIL_DISPATCH(pc)  do { runtime_dispatch(pc); return; } while (0)
#endif
#ifndef GBARECOMP_TAIL_DISPATCH_WITH_EXCHANGE
#define GBARECOMP_TAIL_DISPATCH_WITH_EXCHANGE(pc) \
    do { runtime_dispatch_with_exchange(pc); return; } while (0)
#endif
#ifndef GBARECOMP_TAIL_SWI
#define GBARECOMP_TAIL_SWI(imm)  do { runtime_swi(imm); return; } while (0)
#endif
