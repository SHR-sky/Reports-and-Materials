# R

.data
N: .word 10
X1: .word 1,-4,8,-9,5,6,-10,19,22,23
X2: .word 121,-124,138,-199,255,2566,-1034,1019,2032,2033
ans1: .asciiz "\n the sum of posodd = "
ans2: .asciiz "\n the sum of negeven = "


.text
.globl main

main:
    la $t0 X2
    lw $t1 N
    li $v0 0
    li $v1 0

    loop:
        lw $t2,($t0)

        bgez $t2,judgeodd
        rem $t3,$t2,2
        beqz $t3,addeven
        j next

    judgeodd:
        rem $t4, $t2, 2
        bnez $t4, addodd
        j next

    addodd:
        add $v0, $v0, $t2
        j next

    addeven:
        add $v1, $v1, $t2
        j next

    next:
        addi $t0, $t0, 4
        addi $t1, $t1, -1
        bnez $t1, loop 

    # 打印结果
    move $a1, $v0 # 先把v0中存的数拿出来，避免覆盖
    li $v0, 4 # 操作数为4，系统执行打印a0操作
    la $a0, ans1 # 打印的内容
    syscall # 打印操作
    move $a0, $a1 # 把存的数拿回来，赋值给a0，准备打印
    li $v0, 1 # 操作数1，打印一个整型a0
    syscall # 打印操作

    li $v0, 4 # 操作数为4，系统执行打印a0操作
    la $a0, ans2 # 打印的内容
    syscall # 打印操作
    move $a0, $v1 # 把v1的值赋值给a0，准备打印
    li $v0, 1 # 操作数1，打印一个整型a0
    syscall # 打印操作

    # 退出程序
    li $v0, 10 # 操作数10，退出系统
    syscall # 退出系统




    



