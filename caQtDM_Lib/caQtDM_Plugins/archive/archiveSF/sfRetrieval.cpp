/*
 *  This file is part of the caQtDM Framework, developed at the Paul Scherrer Institut,
 *  Villigen, Switzerland
 *
 *  The caQtDM Framework is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  The caQtDM Framework is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with the caQtDM Framework.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Copyright (c) 2010 - 2014
 *
 *  Author:
 *    Anton Mezger
 *  Contact details:
 *    anton.mezger@psi.ch
 */

#include <QApplication>
#include <QNetworkAccessManager>
#include <QSslConfiguration>
#include <iostream>
#include <QFile>
#include <QDir>
#include <QMutex>
#include <QWaitCondition>
#include <QEventLoop>
#include <QTimer>
#include <time.h>
#include <sys/timeb.h>
#include "sfRetrieval.h"
#include <QDebug>
#include <iostream>
#include <sstream>

#define qasc(x) x.toLatin1().constData()

#ifdef MOBILE_ANDROID
#  include <unistd.h>
#endif


sfRetrieval::sfRetrieval()
{
    finished = false;
    manager = new QNetworkAccessManager(this);
    eventLoop = new QEventLoop(this);
    errorString = "";

    connect(this, SIGNAL(requestFinished()), this, SLOT(downloadFinished()) );
}

void sfRetrieval::timeoutL()
{
    errorString = "http request timeout";
    eventLoop->quit();
}

bool sfRetrieval::requestUrl(const QUrl url, const QByteArray &json, int secondsPast, bool binned)
{
    finished = false;
    totalCount = 0;
    secndsPast = secondsPast;
    QString out = QString(json);
    //printf("caQtDM -- request from %s with %s\n", qasc(url.toString()), qasc(out));
    downloadUrl = url;
    isBinned = binned;
    errorString = "";

    QNetworkRequest *request = new QNetworkRequest(url);

    //for https we need some configuration (with no verify socket)
#ifndef QT_NO_SSL
    if(url.toString().toUpper().contains("HTTPS")) {
        QSslConfiguration config = request->sslConfiguration();
        config.setPeerVerifyMode(QSslSocket::VerifyNone);
        request->setSslConfiguration(config);
    }
#endif
    request->setRawHeader("Content-Type", "application/json");
    request->setRawHeader("Timeout", "86400");

    manager->post(*request, json);

    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(finishReply(QNetworkReply*)));

    finished = false;
    QTimer *timeoutHelper = new QTimer(this);
    timeoutHelper->setInterval(10000);
    timeoutHelper->start();
    connect(timeoutHelper, SIGNAL(timeout()), this, SLOT(timeoutL()));
    eventLoop->exec();

    //downloadfinished will continue
    if(finished) return true;
    else return false;
}

int sfRetrieval::downloadFinished()
{
    eventLoop->quit();
    return finished;
}

void sfRetrieval::finishReply(QNetworkReply *reply)
{
    int count = 0;
    struct timeb now;
    int valueIndex = 2;
    int expected = 4;
    double seconds;
    if(isBinned) {
        valueIndex = 3;
        expected = 6;
    }

    QVariant status =  reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
    if(status.toInt() != 200) {
        errorString = tr("unexpected http status code %1 [%2] from %3").arg(status.toInt()).arg(reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString()).arg(downloadUrl.toString());
        emit requestFinished();
        reply->deleteLater();
        return;
    }

    if(reply->error()) {
        errorString = tr("%1: %2").arg(parseError(reply->error())).arg(downloadUrl.toString());
        emit requestFinished();
        reply->deleteLater();
        return;
    }

    QString out = QString(reply->readAll());
    reply->deleteLater();

    errorString = "";
    ftime(&now);
    seconds = (double) now.time + (double) now.millitm / (double)1000;


#ifdef CSV
    qDebug() << "CSV";
    QStringList result = out.split("\n", QString::SkipEmptyParts);
    //printf("number of values received = %d\n",  result.count());

    if(result.count() < 2) {
        if(result.count() == 1) errorString = tr("result too small %1:[%2]").arg(QString::number(result.count())).arg(result[0]);
        else errorString = tr("result too small %1").arg(QString::number(result.count()));
        emit requestFinished();
        return;
    }

    X.resize(result.count()-1);
    Y.resize(result.count()-1);

    bool ok1, ok2;
    for(int i=1; i< result.count(); ++i) {
        QStringList line = result[i].split(";", QString::SkipEmptyParts);
        //qDebug() << line.count() << valueIndex;
        if(line.count() != expected) {
            errorString = tr("dataline has not the expected number of items %1: [%2]").arg(QString::number(line.count())).arg(expected);
            //qDebug() << "------------------------------- i=" << i << "result" << result[i] << "linecount" << line.count();
            break;
        } else {
            //qDebug() << "i=" << i <<  "linecount" << line.count();
            double archiveTime = line[1].toDouble(&ok1);
            if(ok1) {
                if((seconds - archiveTime) < secndsPast) {
                    X[count] = -(seconds - archiveTime) / 3600.0;
                    Y[count] = line[valueIndex].toDouble(&ok2);             //qDebug() << line[3] << line[4] << line[5]; in case of aggragation
                    //if(count < 10) printf("%f channel=%s seconds=%s value=%s  values=%f %f\n", seconds - line[1].toDouble(), qasc(line[0]),  qasc(line[1]), qasc(line[2]), X[i-1],Y[i-1]);
                    if(ok2) count++;
                    else {
                        errorString = tr("could not decode value %1 at position %2").arg(line[valueIndex].arg(valueIndex));
                        break;
                    }
                }
            } else {
                errorString = tr("could not decode time %1 at position").arg(line[1].arg(1));
                break;
            }
        }
    }
    totalCount = count;

#else

    totalCount = 0;
    int stat;
    Backend = "";

    JSONValue *value = JSON::Parse(qasc(out));
    //printf("\n\nout: %s\n\n", qasc(out));

    // Did it go wrong?
    if (value == NULL) {
        errorString = tr("could not parse json string %1").arg(out);
        emit requestFinished();
        return;
    } else {

        if(!value->IsArray()) {
            qDebug() << "the json root element is not an array, something has changed";
        }

        if(value->IsArray()) {
            JSONArray array = value->AsArray();

            for (unsigned int i = 0; i < array.size(); i++) {
                JSONValue *value = JSON::Parse(array[i]->Stringify().c_str());

                if(value->IsObject()) {

                    JSONObject root;
                    root = value->AsObject();

                    // find channel data inside this part of array
                    if (root.find(L"channel") != root.end() && root[L"channel"]->IsObject()) {
                        //qDebug() << "\nchannel part found as object";
                        JSONValue *value = JSON::Parse(root[L"channel"]->Stringify().c_str());
                        JSONObject root0 = value->AsObject();

                        // get channel name
                        if (root0.find(L"name") != root0.end() && root0[L"name"]->IsString()) {
                            char channel[80];
                            stat = swscanf(root0[L"name"]->Stringify().c_str(), L"%s", channel);
                            //qDebug()<< "channel name found" << root0[L"name"]->AsString().c_str(); << backend
                        }

                        // get backend name
                        if (root0.find(L"backend") != root0.end() && root0[L"backend"]->IsString()) {
                            char backend[80];
                            stat = swscanf(root0[L"backend"]->Stringify().c_str(), L"%s", backend);
                            Backend = QString(backend);
                            Backend = Backend.replace("\"", "");
                            //qDebug()<< "backend name found" << root0[L"backend"]->AsString().c_str() << backend;
                        }

                    }

                    // find data array inside this part of array
                    if (root.find(L"data") != root.end() && root[L"data"]->IsArray()) {
                        JSONArray array = root[L"data"]->AsArray();
                        //qDebug() << "\ndata part found as array";

                        // scan the data part (big array)
                        if(array.size() < 1) {
                            errorString = tr("no data");
                            emit requestFinished();
                            return;
                        }

                        // set array size
                        X.resize(array.size());
                        Y.resize(array.size());

                        // binned data
                        if(isBinned) {

                            for (unsigned int i = 0; i < array.size(); i++) {
                                bool valueFound = false;
                                bool timeFound = false;
                                double mean;
                                double archiveTime;

                                // find value part now
                                JSONObject root1 = array[i]->AsObject();
                                if (root1.find(L"value") != root1.end() && root1[L"value"]->IsObject()) {
                                    JSONValue *value = JSON::Parse(root1[L"value"]->Stringify().c_str());
                                    JSONObject root2 = value->AsObject();

                                    // look for mean
                                    if (root2.find(L"mean") != root2.end() && root2[L"mean"]->IsNumber()) {
                                        //qDebug() << "mean part found";
                                        stat = swscanf(root2[L"mean"]->Stringify().c_str(), L"%lf", &mean);
                                        valueFound = true;
                                    }
                                }

                                // look for iocseconds
                                if (root1.find(L"iocSeconds") != root1.end() && root1[L"iocSeconds"]->IsString()) {
                                    //qDebug()<< "iocSeconds part found";
                                    if(getDoubleFromString(QString::fromWCharArray(root1[L"iocSeconds"]->AsString().c_str()), archiveTime)){
                                       timeFound = true;
                                    } else {
                                        qDebug() << tr("could not decode iocSeconds ????");
                                        break;
                                    }
                                }

                                // fill in our data
                                if(timeFound && valueFound && (seconds - archiveTime) < secndsPast) {
                                    X[count] = -(seconds - archiveTime) / 3600.0;
                                    Y[count] = mean;
                                    count++;
                                }

                            }

                            // non binned data
                        } else {

                            bool valueFound = false;
                            bool timeFound = false;
                            double mean;
                            double archiveTime;
                            for (unsigned int i = 0; i < array.size(); i++) {
                                JSONObject root1 = array[i]->AsObject();
                                if (root1.find(L"value") != root1.end() && root1[L"value"]->IsNumber()) {
                                    //qDebug() << "value found";
                                    stat = swscanf(root1[L"value"]->Stringify().c_str(), L"%lf", &mean);
                                    valueFound = true;
                                }
                                if (root1.find(L"iocSeconds") != root1.end() && root1[L"iocSeconds"]->IsString()) {
                                    //qDebug() << "iocSeconds found"<<QString::fromWCharArray(root1[L"iocSeconds"]->AsString().c_str());
                                    if(getDoubleFromString(QString::fromWCharArray(root1[L"iocSeconds"]->AsString().c_str()), archiveTime)){
                                       timeFound = true;
                                    } else {
                                        qDebug() << tr("could not decode iocSeconds ????");
                                        break;
                                    }
                                }

                                // fill in our data
                                if(timeFound && valueFound && (seconds - archiveTime) < secndsPast) {
                                    X[count] = -(seconds - archiveTime) / 3600.0;
                                    Y[count] = mean;
                                    count++;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    totalCount = count;
    //qDebug() << "totalcount =" << count;

#endif

    finished = true;
    emit requestFinished();
}

bool sfRetrieval::getDoubleFromString(QString input, double &value) {
    bool ok;
    value = input.toDouble(&ok);
    if(ok) {
        return true;
    } else {
        return false;
    }
}

int sfRetrieval::getCount()
{
    return totalCount;
}

const QString sfRetrieval::getBackend()
{
    return Backend;
}

void sfRetrieval::getData(QVector<double> &x, QVector<double> &y)
{
    x = X;
    y = Y;
}

const QString sfRetrieval::lastError()
{
    return errorString;
}

const QString sfRetrieval::parseError(QNetworkReply::NetworkError error)
{
    QString errstr = "";
    switch(error)
    {
    case QNetworkReply::ConnectionRefusedError:
        errstr = tr("ConnectionRefusedError");
        break;
    case QNetworkReply::RemoteHostClosedError:
        errstr = tr("RemoteHostClosedError");
        break;
    case QNetworkReply::HostNotFoundError:
        errstr = tr("HostNotFoundError");
        break;
    case QNetworkReply::TimeoutError:
        errstr = tr("TimeoutError");
        break;
    case QNetworkReply::OperationCanceledError:
        errstr = tr("OperationCanceledError");
        break;
    case QNetworkReply::SslHandshakeFailedError:
        errstr = tr("SslHandshakeFailedError");
        break;
    case QNetworkReply::TemporaryNetworkFailureError:
        errstr = tr("TemporaryNetworkFailureError");
        break;
    case QNetworkReply::ProxyConnectionRefusedError:
        errstr = tr("ProxyConnectionRefusedError");
        break;
    case QNetworkReply::ProxyConnectionClosedError:
        errstr = tr("ProxyConnectionClosedError");
        break;
    case QNetworkReply::ProxyNotFoundError:
        errstr = tr("ProxyNotFoundError");
        break;
    case QNetworkReply::ProxyTimeoutError:
        errstr = tr("ProxyTimeoutError");
        break;
    case QNetworkReply::ProxyAuthenticationRequiredError:
        errstr = tr("ProxyAuthenticationRequiredError");
        break;
    case QNetworkReply::ContentAccessDenied:
        errstr = tr("ContentAccessDenied");
        break;
    case QNetworkReply::ContentOperationNotPermittedError:
        errstr = tr("ContentOperationNotPermittedError");
        break;
    case QNetworkReply::ContentNotFoundError:
        errstr = tr("ContentNotFoundError");
        break;
    case QNetworkReply::AuthenticationRequiredError:
        errstr = tr("AuthenticationRequiredError");
        break;
    case QNetworkReply::ProtocolUnknownError:
        errstr = tr("ProtocolUnknownError");
        break;
    case QNetworkReply::ProtocolInvalidOperationError:
        errstr = tr("ProtocolInvalidOperationError");
        break;
    case QNetworkReply::UnknownNetworkError:
        errstr = tr("UnknownNetworkError");
        break;
    case QNetworkReply::UnknownProxyError:
        errstr = tr("UnknownProxyError");
        break;
    case QNetworkReply::UnknownContentError:
        errstr = tr("UnknownContentError");
        break;
    case QNetworkReply::ProtocolFailure:
        errstr = tr("ProtocolFailure");
        break;
    default:
        errstr = tr("unknownError %1").arg(error);
        break;
    }
    return errstr;
}
