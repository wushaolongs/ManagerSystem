//
//  main.c
//  StudentManagerSystem
//
//  Created by 阿炮 on 2024/3/12.
//


#include "StudentManagerSystem.h"

int main(int argc, const char * argv[]) {
    // insert code here...
    
    while (1) {
     
        Welcome();
        
        //从键盘接收一个字符
        //scanf
        //getch
        
        char ch = getchar();
        
        switch (ch) {
            case '1':
                // 录入学生信息
                inputStudent();
                break;
            case '2':
                //打印学生信息
                PrintStudent();
                break;
            case '3':
                //保存学生信息
                SaveStudent();
                break;
            case '4':
                //读取学生信息
                ReadStudent();
                break;
            case '5':
                //统计所有学生人数
                break;
            case '6':
                //查找学生信息
                break;
            case '7':
                //修改学生信息
                break;
            case '8':
                //删除学生信息
                break;
            case '0':
                //退出系统
                break;
            default:
                break;
        }
    }
    
    return 0;
}


void Welcome(void){
    
    printf("*************************************************************\n");
    printf("*\t\t\t\t\t欢迎使用高校学生成绩管理系统v1.0\t\t\t\t*\n");
    printf("*************************************************************\n");
    printf("*\t\t\t\t\t\t请选择功能列表\t\t\t\t\t\t\t*\n");
    printf("*************************************************************\n");
    printf("*\t\t\t\t\t\t1.录入学生信息\t\t\t\t\t\t\t*\n");
    printf("*\t\t\t\t\t\t2.打印学生信息\t\t\t\t\t\t\t*\n");
    printf("*\t\t\t\t\t\t3.保存学生信息\t\t\t\t\t\t\t*\n");
    printf("*\t\t\t\t\t\t4.读取学生信息\t\t\t\t\t\t\t*\n");
    printf("*\t\t\t\t\t\t5.统计所有学生人数\t\t\t\t\t\t*\n");
    printf("*\t\t\t\t\t\t6.查找学生信息\t\t\t\t\t\t\t*\n");
    printf("*\t\t\t\t\t\t7.修改学生信息\t\t\t\t\t\t\t*\n");
    printf("*\t\t\t\t\t\t8.删除学生信息\t\t\t\t\t\t\t*\n");
    printf("*\t\t\t\t\t\t0.退出系统\t\t\t\t\t\t\t*\n");
    printf("*************************************************************\n");
    
    system("pause");
    
}

void inputStudent(void){
    
    //创建一个新节点
    Node *pNewNode = (Node*)malloc(sizeof(Node));
    
    //头插法、尾插法
    //头插法
    if (g_pHead == NULL){
        g_pHead = pNewNode;
    }else{
        pNewNode->pNext = g_pHead;
        g_pHead = pNewNode;
    }
    
    printf("请输入学生信息:\n");
    scanf("%s",pNewNode->stu.name); //从键盘格式化接受一个字符串，整数等等
    printf("请输入学生的年龄：\n");
    scanf("%d",&pNewNode->stu.age); //  &:取地址运算符
    printf("请输入学生的学号:\n");
    scanf("%d",&pNewNode->stu.stuNum);    //
    printf("请输入学生的成绩");
    scanf("%d",&pNewNode->stu.sore);
    
    printf("学生信息录入成功.\n");
    system("pause");
    system("cls");  //清除屏幕
}

void PrintStudent(void){
    printf("*************************************************************\n");
    printf("*\t\t\t\t\t欢迎使用高校学生成绩管理系统v1.0\t\t\t\t*\n");
    printf("*************************************************************\n");
    printf("*\t学号\t*\t姓名\t*\t年龄\t*\t成绩*\n");
    printf("*************************************************************\n");
    
    //    遍历链表
    Node* p = g_pHead;
    while (p != NULL) {
        printf("*\t%d\t*\t%s\t*\t%d\t*\t*d*\n",p->stu.stuNum,p->stu.name,p->stu.age,p->stu.sore);
        p = p->pNext;
    }
    
    printf("*************************************************************\n");
    system("pause");
    system("cls");  //清除屏幕
}

void SaveStudent(void){
    
    //打开文件
    FILE* fp = fopen("/Users/cakes/Documents/C/CPP/StudentManagerSystem/data.txt", "w");
    if (fp == NULL){
        printf("打开文件失败.\n");
        return;
    }
    
    //遍历链表
    Node* p = g_pHead;
    while (p != NULL) {
        
        fwrite(&p->stu, 1, sizeof(Student), fp);
        p = p->pNext;
    }
    
    // 关闭文件
    fclose(fp);
    printf("数据保存成功\n");
    system("pause");
    system("cls");  //清除屏幕
}

void ReadStudent(void){
    
    //打开文件
    FILE *fp  = fopen("/Users/cakes/Documents/C/CPP/StudentManagerSystem/data.txt", "r");
    if (fp == NULL){
        printf("打开文件失败\n");
        return;
    }
    
    //读文件
    while (!feof(fp)) {
        //创建一个新节点
        Node* pNewNode = malloc(sizeof(Node));
        fread(&pNewNode->stu, 1, sizeof(Student), fp);
        
        pNewNode->pNext = NULL;
        
        //头插法
        if (g_pHead == NULL) {
            g_pHead = pNewNode;
        }else{
            pNewNode->pNext = g_pHead;
            g_pHead = pNewNode;
        }
    }
    
    //关闭文件
    fclose(fp);
    printf("加载数据成功\n");
}
