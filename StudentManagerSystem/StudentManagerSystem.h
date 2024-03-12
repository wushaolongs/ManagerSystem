//
//  StudentManagerSystem.h
//  StudentManagerSystem
//
//  Created by 阿炮 on 2024/3/12.
//

#ifndef StudentManagerSystem_h
#define StudentManagerSystem_h

#include <stdio.h>
//#include <curses.h>
#include <stdlib.h>

// 定义一个学生
typedef struct _Student{
    char name[20];  //姓名
    int age;    //年龄
    int stuNum;     //学号
    int sore;   //成绩
}Student;

//节点(车厢)
typedef struct _Node {
    Student stu;    //学生
    struct _Node *pNext;    //指向下一个节点的指针
}Node;

Node *g_pHead = NULL; //头节点

//欢迎
void Welcome(void);
//录入学生信息
void inputStudent(void);
//打印学生信息
void PrintStudent(void);
//保存学生信息
void SaveStudent(void);
//读取学生信息
void ReadStudent(void);



#endif /* StudentManagerSystem_h */
