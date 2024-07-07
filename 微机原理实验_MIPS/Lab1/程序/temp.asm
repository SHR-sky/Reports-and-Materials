.data
array1: .word 1,-4,8,-9,5,6,-10,19,22,23
array2: .word 121,-124,-199,255,2566,-1034,1019,2032,2033 
length: .word 10
posSumMsg: .asciiz "\n the sum of positive odd = "
negSumMsg: .asciiz "\n the sum of negitive even = "
posSum: .word 0
negSum: .word 0

.text
.globl main

main:
    # 加载数组地址和长度
    la $t0, array1   # 存地址
    lw $t1, length   # 初始化长度
    li $v0, 0 #存正奇数
    li $v1, 0 #存负偶数

    # 遍历数组
    loop:
        lw $t2, ($t0)  # 加载 array[i]

        # 检查正奇数或负偶数
        bgez $t2, checkPosOdd # 大于等于0
        rem $t4, $t2, 2 # 剩下的都是小于0的，数组元素对2取模，负偶数则满足等于0
        beqz $t4, addNegEven # 等于0
        j nextIteration # 进入nextIteration
        
    addNegEven:
        add $v1, $v1, $t2

    checkPosOdd:
        rem $t3, $t2, 2
        bnez $t3, addPosOdd # 不等于0，即有余数1，则加到奇数和中
        j nextIteration

    addPosOdd:
        add $v0, $v0, $t2  # 正奇数的和

    nextIteration:
        addi $t0, $t0, 4  # 移至下一个元素
        addi $t1, $t1, -1
        bnez $t1, loop  # 如果未完成，继续循环

    # 打印结果
    move $a1, $v0 # 先把v0中存的数拿出来，避免覆盖
    li $v0, 4 # 操作数为4，系统执行打印a0操作
    la $a0, posSumMsg # 打印的内容
    syscall # 打印操作
    move $a0, $a1 # 把存的数拿回来，赋值给a0，准备打印
    li $v0, 1 # 操作数1，打印一个整型a0
    syscall # 打印操作

    li $v0, 4 # 操作数为4，系统执行打印a0操作
    la $a0, negSumMsg # 打印的内容
    syscall # 打印操作
    move $a0, $v1 # 把v1的值赋值给a0，准备打印
    li $v0, 1 # 操作数1，打印一个整型a0
    syscall # 打印操作

    # 退出程序
    li $v0, 10 # 操作数10，退出系统
    syscall # 退出系统