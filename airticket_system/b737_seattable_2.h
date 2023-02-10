#ifndef B737_SEATTABLE_2_H
#define B737_SEATTABLE_2_H

#include <QDialog>

namespace Ui {
class B737_seatTable_2;
}

class B737_seatTable_2 : public QDialog
{
    Q_OBJECT

public:
    explicit B737_seatTable_2(QWidget *parent = nullptr);
    ~B737_seatTable_2();
    void paintEvent(QPaintEvent *);
    void mousePressEvent(QMouseEvent *);
    void mouseMoveEvent(QMouseEvent * event);
    void createArray();   //生成各类数组
    void exchange(QString seatnum);  //将数据库中的座位号转换为数组中对应的下标
    void fillTable();  //初始化seat_table数组
    QString numToChar(int num);  //将选好的座位的下标变为对应的字符

    QString airnum,date,class_level;  //根据航班号和航班日期查询乘坐该航班的乘客信息
    int amount,count = 0;     //记录有几张机票,以及选了几张座
    int *X,*Y;   //存放选中座位的下标
    int a,b;     //记录鼠标点击的座椅下标
    int moveX,moveY; //记录鼠标移动的坐标
    QString *seatnum;   //用于存放座位号的数组指针
private slots:
    void on_pushButton_2_clicked();

    void on_pushButton_clicked();

private:
    Ui::B737_seatTable_2 *ui;
    int seat_table[25][7]={};
};

#endif // B737_SEATTABLE_2_H
