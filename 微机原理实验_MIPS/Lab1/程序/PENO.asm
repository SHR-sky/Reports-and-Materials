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

    # ��ӡ���
    move $a1, $v0 # �Ȱ�v0�д�����ó��������⸲��
    li $v0, 4 # ������Ϊ4��ϵͳִ�д�ӡa0����
    la $a0, ans1 # ��ӡ������
    syscall # ��ӡ����
    move $a0, $a1 # �Ѵ�����û�������ֵ��a0��׼����ӡ
    li $v0, 1 # ������1����ӡһ������a0
    syscall # ��ӡ����

    li $v0, 4 # ������Ϊ4��ϵͳִ�д�ӡa0����
    la $a0, ans2 # ��ӡ������
    syscall # ��ӡ����
    move $a0, $v1 # ��v1��ֵ��ֵ��a0��׼����ӡ
    li $v0, 1 # ������1����ӡһ������a0
    syscall # ��ӡ����

    # �˳�����
    li $v0, 10 # ������10���˳�ϵͳ
    syscall # �˳�ϵͳ




    



