import React, { FC, useState, useEffect } from 'react';
import { InteractiveBrowserCredential } from '@azure/identity';
import { BlobServiceClient, BlobItem } from '@azure/storage-blob';

type BlobViewProps = {
    clientId: string;
    tenantId: string;
    storageAccount: string;
    imageFuncUrl: string;
}

const BlobView: FC<BlobViewProps> = (props) => {
    const [blobList, setBlobList] = useState<Array<BlobItem>>([]);

    useEffect(() => {
        const signInOptions = {
            clientId: props.clientId,
            tenantId: props.tenantId
        }

        const blobStorageClient = new BlobServiceClient(
            `https://${props.storageAccount}.blob.core.windows.net/`,
            new InteractiveBrowserCredential(signInOptions)
        )

        const fetchData = async () => {
            var containerClient = blobStorageClient.getContainerClient("images");
            var localBlobList = [];
            let iterator = await containerClient.listBlobsFlat().byPage({maxPageSize: 5});
            let response = (await iterator.next()).value;

            for (const blob of response.segment.blobItems) {
                localBlobList.push(blob);
            }
            setBlobList(localBlobList);
        }

        fetchData();
    }, [props]);

    return (
        <div>
            <div className="health-record__header">
                <div className="header-title">Images from Storage</div>
                <div><button className="button">Analyze</button></div>
                <div className="header-divider"></div>
            </div>
            <table className="table table-sm table-hover">
                <thead>
                    <tr>
                        <th></th>
                        <th>Thumbnail</th>
                        <th>Image Name</th>
                        <th>Size</th>
                    </tr>
                </thead>
                <tbody>{
                    blobList.map((x, i) => {
                        return <tr key={i}>
                            <td><input type="checkbox" id={x.name}/></td>
                            <td>
                                <img height="100" width="100" alt={x.name} src={props.imageFuncUrl + x.name} />
                            </td>
                            <td>{x.name}</td>
                            <td>{x.properties.contentLength}</td>                            
                        </tr>
                    })
                }
                </tbody>
            </table>
        </div>
    )
}

export default BlobView;